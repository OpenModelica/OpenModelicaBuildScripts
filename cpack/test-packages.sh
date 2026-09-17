#!/usr/bin/env bash
#
# Install OpenModelica packages into a clean system and simulate a model.
#
#   cpack/test-packages.sh <package-dir> [package-name ...]
#
# Run this as root inside a fresh container of the distribution the packages were
# built for, e.g.
#
#   docker run --rm -v "$PWD:/work:ro" ubuntu:24.04 \
#     /work/cpack/test-packages.sh /work/packages
#
# The .deb or .rpm files in <package-dir> are served from a local repository, and
# only the named packages (default: openmodelica-omc) are installed from it. Their
# dependencies on each other are then resolved by apt or dnf the way they are for a
# user, which is the point: installing the files by name, or with dpkg -i, pulls in
# whatever you name and so hides a dependency that is missing from the metadata.
#
# Passes when omc runs and compiles and simulates a model to a result file.

set -euo pipefail

die() {
  echo "test-packages.sh: $*" >&2
  exit 1
}

step() {
  echo
  echo "==> $*"
}

[ $# -ge 1 ] || die "usage: $0 <package-dir> [package-name ...]"
package_dir="$1"; shift
[ -d "$package_dir" ] || die "$package_dir is not a directory"
packages=("$@")
[ ${#packages[@]} -gt 0 ] || packages=(openmodelica-omc)

[ "$(id -u)" = 0 ] || die "must run as root, in a system it is fine to install packages into"

shopt -s nullglob
debs=("$package_dir"/*.deb)
rpms=("$package_dir"/*.rpm)

repo=/var/local/openmodelica-test-repo
rm -rf "$repo"
mkdir -p "$repo"

## Local repository and install ###################################################################

if [ ${#debs[@]} -gt 0 ]; then
  export DEBIAN_FRONTEND=noninteractive
  step "Local apt repository with ${#debs[@]} packages"
  apt-get update -qq
  apt-get install -qy --no-install-recommends dpkg-dev >/dev/null
  cp "${debs[@]}" "$repo/"
  (cd "$repo" && dpkg-scanpackages . > Packages)
  echo "deb [trusted=yes] file:$repo ./" > /etc/apt/sources.list.d/openmodelica-test.list
  # apt looks for compressed variants of the index first and warns about each one
  # that is missing; only the uncompressed Packages is needed.
  apt-get update -qq 2> >(grep -v "^W: Symlinking file" >&2)

  step "apt-get install ${packages[*]}"
  apt-get install -qy "${packages[@]}"
  # shellcheck disable=SC2016 # dpkg-query's own ${...} format, not the shell's
  installed() { dpkg-query -W -f='${Package} ${Version}\n' 'openmodelica*' 2>/dev/null || true; }

elif [ ${#rpms[@]} -gt 0 ]; then
  step "Local dnf repository with ${#rpms[@]} packages"
  dnf install -qy createrepo_c >/dev/null
  cp "${rpms[@]}" "$repo/"
  createrepo_c -q "$repo"
  printf '[openmodelica-test]\nname=OpenModelica packages under test\nbaseurl=file://%s\ngpgcheck=0\nenabled=1\n' \
    "$repo" > /etc/yum.repos.d/openmodelica-test.repo

  step "dnf install ${packages[*]}"
  dnf install -y "${packages[@]}"
  installed() { rpm -qa --qf '%{NAME} %{VERSION}-%{RELEASE}\n' 'openmodelica*' || true; }

else
  die "no .deb or .rpm files in $package_dir"
fi

step "Installed"
installed | sort | sed 's/^/    /'

## Use it #########################################################################################

step "omc --version"
command -v omc >/dev/null || die "omc is not on PATH after installing ${packages[*]}"
omc --version

step "Compile and simulate a model"
work="$(mktemp -d)"
cat > "$work/test.mos" <<'EOF'
loadString("model M Real x(start=1, fixed=true); equation der(x) = -x; end M;"); getErrorString();
simulate(M, stopTime=1.0); getErrorString();
EOF
# omc keeps its settings and library cache in $HOME.
(cd "$work" && HOME="$work" omc test.mos)

# simulate() returns a record rather than failing, so judge it by what it left behind.
[ -s "$work/M_res.mat" ] ||
  die "simulate() produced no result file; the compile or the simulation failed (output above)"

step "OK: the packages install, and omc simulates a model"
