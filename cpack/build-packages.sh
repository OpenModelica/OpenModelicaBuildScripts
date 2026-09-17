#!/usr/bin/env bash
#
# Build the OpenModelica Linux packages with CMake and CPack.
#
#   cpack/build-packages.sh [options] <openmodelica-source-dir> [-- <extra cmake args>]
#
# Configures, builds and installs OpenModelica, downloads the Modelica library
# cache, and runs `cpack -G DEB` (or RPM) on the result. The .deb/.rpm files end
# up in the output directory.
#
# What goes into which package -- names, contents, dependencies -- is defined in
# the OpenModelica repository, in cmake/packaging/. This script only decides how
# OpenModelica is *built* for a package: which features are on, which compiler
# and Qt it uses. It needs a git checkout with its tags (the package version is
# derived from `git describe`) and the build dependencies of the distribution it
# runs on, e.g. a ghcr.io/openmodelica/build-deps image.
#
# Options:
#   -G, --generator DEB|RPM  Package format. Default: DEB if dpkg-deb is available,
#                            otherwise RPM.
#   -B, --build-dir DIR      Build directory. Default: <source>/build_packages
#   -o, --output DIR         Where the packages are copied. Default: ./packages
#   -j, --jobs N             Parallel build jobs. Default: nproc
#       --no-omlibrary       Do not download the Modelica library cache, and leave
#                            the (then empty) omlibrary package out. The download
#                            needs network access.
#       --cpack-arg ARG      Pass ARG to cpack; may be repeated, e.g.
#                            --cpack-arg -DCPACK_COMPONENTS_ALL="omc;simrt"
#   -h, --help               Show this help.
#
# Everything after `--` is appended to the cmake configure line and wins over the
# defaults below, e.g. `-- -DOM_USE_CCACHE=ON -DOM_QT_MAJOR_VERSION=5`.
#
# The compiler is clang when it is installed, as for the Autoconf packages; set CC
# and CXX to use a different one.

set -euo pipefail

usage() {
  sed -n '3,/^$/{s/^# \{0,1\}//;p}' "$0"
}

die() {
  echo "build-packages.sh: $*" >&2
  exit 1
}

step() {
  echo
  echo "==> $*"
}

generator=""
build_dir=""
output_dir="$PWD/packages"
jobs="$(nproc)"
omlibrary=1
source_dir=""
cmake_args=()
cpack_args=()

while [ $# -gt 0 ]; do
  case "$1" in
    -G|--generator)  generator="${2:?$1 needs a value}"; shift 2 ;;
    -B|--build-dir)  build_dir="${2:?$1 needs a value}"; shift 2 ;;
    -o|--output)     output_dir="${2:?$1 needs a value}"; shift 2 ;;
    -j|--jobs)       jobs="${2:?$1 needs a value}"; shift 2 ;;
    --no-omlibrary)  omlibrary=0; shift ;;
    --cpack-arg)     cpack_args+=("${2:?$1 needs a value}"); shift 2 ;;
    -h|--help)       usage; exit 0 ;;
    --)              shift; cmake_args=("$@"); break ;;
    -*)              die "unknown option $1 (see --help)" ;;
    *)               [ -z "$source_dir" ] || die "more than one source directory given"
                     source_dir="$1"; shift ;;
  esac
done

[ -n "$source_dir" ] || { usage >&2; exit 2; }
[ -f "$source_dir/CMakeLists.txt" ] || die "$source_dir is not an OpenModelica source tree"
source_dir="$(cd "$source_dir" && pwd)"
build_dir="${build_dir:-$source_dir/build_packages}"
mkdir -p "$output_dir"
output_dir="$(cd "$output_dir" && pwd)"

## Package format #################################################################################

if [ -z "$generator" ]; then
  if command -v dpkg-deb >/dev/null; then
    generator=DEB
  elif command -v rpmbuild >/dev/null; then
    generator=RPM
  else
    die "found neither dpkg-deb nor rpmbuild; pass -G"
  fi
fi

case "$generator" in
  DEB)
    # dpkg-shlibdeps works out the Depends: (CPACK_DEBIAN_PACKAGE_SHLIBDEPS), and it is
    # only called once everything is built. Check now rather than after the build.
    if ! command -v dpkg-deb >/dev/null || ! command -v dpkg-shlibdeps >/dev/null; then
      die "DEB packages need dpkg-deb and dpkg-shlibdeps (package dpkg-dev)"
    fi
    ext=deb ;;
  RPM)
    command -v rpmbuild >/dev/null || die "RPM packages need rpmbuild (package rpm-build)"
    ext=rpm ;;
  *)
    die "unsupported generator '$generator'; use DEB or RPM" ;;
esac

# A package without a version never upgrades, so OpenModelica's CPack configuration
# refuses to build one -- but only at the very end. Catch the usual cause, a checkout
# without its tags, before spending hours on the build. Same `git describe` as
# OpenModelica's cmake/omc_git_revision.cmake, minus its --always fallback.
if [ ! -f "$source_dir/OMVERSION.txt" ] &&
   ! git -C "$source_dir" describe --match 'v*.*' >/dev/null 2>&1; then
  die "cannot derive a version: $source_dir has no OMVERSION.txt and \`git describe\` finds no v*.* tag. \
Clone with the tags and without --depth. (In a container, a checkout owned by another \
user also needs \`git config --global --add safe.directory '*'\`.)"
fi

## Build policy ###################################################################################

arch="$(uname -m)"

# The C++ simulation runtime needs a full Boost; it has never been shipped on armhf.
case "$arch" in
  armv7l|armhf) cpp_runtime=OFF ;;
  *)            cpp_runtime=ON ;;
esac

# OMEdit needs QtWebEngine. Qt 6 wherever its WebEngine is installed, Qt 5 on the
# distributions that only have the Qt 5 one.
#
# Judged by what find prints, not by its exit status: find exits 1 as soon as any
# directory below /usr or /opt is unreadable, even when it did find the file, and
# under pipefail that silently turned a Qt 6 system into a Qt 5 build.
qt6_webengine="$(find /usr /opt -name Qt6WebEngineWidgetsConfig.cmake -print -quit 2>/dev/null || true)"
if [ -n "$qt6_webengine" ]; then
  qt_major=6
else
  qt_major=5
fi

if [ -z "${CC:-}" ] && command -v clang >/dev/null && command -v clang++ >/dev/null; then
  export CC=clang CXX=clang++
fi

cmake_generator=()
if command -v ninja >/dev/null; then
  cmake_generator=(-G Ninja)
fi

# The staging prefix is only where `install` puts things so that omc can run to
# download the library cache. The packages are laid out by CPack itself
# (CPACK_PACKAGING_INSTALL_PREFIX); omc finds its files relative to its own binary,
# so the two do not have to agree.
stage_dir="$build_dir/stage"

default_args=(
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX="$stage_dir"
  -DOM_USE_CCACHE=OFF
  # The testsuite would build omc-diff into 'all' and install it with omc.
  -DOM_ENABLE_TESTSUITE=OFF
  -DOM_ENABLE_GUI_CLIENTS=ON
  -DOM_QT_MAJOR_VERSION="$qt_major"
  -DOM_ENABLE_OMSIMULATOR=ON
  -DOM_OMC_ENABLE_CPP_RUNTIME="$cpp_runtime"
  -DOM_OMOPTIM_ENABLE=OFF
  -DOM_ENABLE_ENCRYPTION=OFF
)

step "Building $generator packages of $source_dir"
echo "    build directory: $build_dir"
echo "    architecture:    $arch (C++ runtime $cpp_runtime)"
echo "    Qt:              $qt_major"
echo "    compiler:        ${CC:-cmake default}"

## Configure, build, install ######################################################################

step "Configure"
cmake -S "$source_dir" -B "$build_dir" "${cmake_generator[@]}" "${default_args[@]}" "${cmake_args[@]}"

# The same check as above, from the source of truth: what CPack was actually given.
# OpenModelica leaves CPack's 0.1.1 default in place when it cannot derive a version.
if grep -q '^set(CPACK_PACKAGE_VERSION "0\.1\.1")' "$build_dir/CPackConfig.cmake"; then
  die "OpenModelica derived no package version (see OM_PACKAGE_VERSION in the configure output)"
fi

step "Build"
cmake --build "$build_dir" --parallel "$jobs"

step "Install into $stage_dir"
cmake --install "$build_dir"

# The component list CPack would pack. OpenModelica derives it from what this build
# configured, see cmake/packaging/components.cmake.
components="$(sed -n 's/^set(CPACK_COMPONENTS_ALL "\(.*\)")$/\1/p' "$build_dir/CPackConfig.cmake")"

if [ "$omlibrary" = 1 ]; then
  # Runs the staged omc, which is why it comes after the install.
  step "Download the Modelica library cache"
  cmake --build "$build_dir" --target omlibrary
else
  # Without the download its package would hold nothing but an empty directory.
  components="$(printf '%s' "$components" | tr ';' '\n' | { grep -vx omlibrary || true; } | paste -sd ';' -)"
  cpack_args=(-D "CPACK_COMPONENTS_ALL=$components" "${cpack_args[@]}")
fi

## Package ########################################################################################

step "Package ($components)"
# Stale packages from an earlier run would otherwise be copied out with the new ones.
rm -rf "$build_dir/_packages"
(cd "$build_dir" && cpack -G "$generator" "${cpack_args[@]}")

shopt -s nullglob
packages=("$build_dir"/_packages/*."$ext")
[ ${#packages[@]} -gt 0 ] || die "cpack produced no .$ext files"
cp "${packages[@]}" "$output_dir/"

step "Built ${#packages[@]} packages into $output_dir"
for p in "${packages[@]}"; do
  echo "    $(basename "$p")"
done
