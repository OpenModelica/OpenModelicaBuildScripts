#!/bin/sh
# Static validation of rpm/SPECS/openmodelica.spec.tpl.
#
# The template is not a valid spec file on its own: the RPM job in the apt-build
# repository substitutes a set of upper-case placeholders into it before calling
# rpmbuild (see the rpmInfo map in apt-build's Jenkinsfile).  This script does
# the same substitution with representative values and then asks rpm itself to
# parse the result, which catches the syntax mistakes that have broken nightly
# RPM builds before: a missing %, an empty %define, a stray comment.
#
# It does not build anything, so it says nothing about BuildRequires being
# installable or the %files list matching what the build produces.
#
# Run it from the top of the repository, inside a distribution we ship for:
#
#   docker run --rm -v "$PWD:/src" -w /src fedora:43 sh -c \
#     'dnf install -y rpm-build >/dev/null && .ci/check-rpm-spec.sh'

set -eu

TEMPLATE=rpm/SPECS/openmodelica.spec.tpl

# Representative values, in the order the Jenkins job applies them.  They only
# have to be shaped like the real thing; the point is to parse the spec.
NAME=openmodelica-nightly
DEBVERSION=1.28.0~dev-489-gda9d1ce
RPMVERSION=1.28.0~dev~489~gda9d1ce
CONFIGUREFLAGS=
DOCUMENTATIONVERSION=latest
PATCHCMDS=
PATCHES=
PRIORITY=1018000
PRIVATELIBS='lib.*Modelica.*|lib[oO][mM][^n].*[.]so.*|libklu[.]so.*|libsundials.*'
RELEASENUM=1
BRANCH=nightly
DATE=$(LC_ALL=C date "+%a %b %d %Y")

command -v rpmspec >/dev/null 2>&1 || {
  echo "rpmspec not found; install rpm-build" >&2
  exit 2
}

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
spec="$scratch/openmodelica.spec"

# '%' is safe as the sed delimiter: none of the values above contain one.
sed -e "s%NAME%$NAME%g" \
    -e "s%DEBVERSION%$DEBVERSION%g" \
    -e "s%RPMVERSION%$RPMVERSION%g" \
    -e "s%CONFIGUREFLAGS%$CONFIGUREFLAGS%g" \
    -e "s%DOCUMENTATIONVERSION%$DOCUMENTATIONVERSION%g" \
    -e "s%PATCHCMDS%$PATCHCMDS%g" \
    -e "s%PATCHES%$PATCHES%g" \
    -e "s%PRIORITY%$PRIORITY%g" \
    -e "s%PRIVATELIBS%$PRIVATELIBS%g" \
    -e "s%RELEASENUM%$RELEASENUM%g" \
    -e "s%BRANCH%$BRANCH%g" \
    -e "s%DATE%$DATE%g" \
    "$TEMPLATE" > "$spec"

echo "rpm $(rpm --version | awk '{print $3}') on $(. /etc/os-release; echo "$PRETTY_NAME")"

if ! out=$(rpmspec -P "$spec" 2>&1 >/dev/null); then
  printf '%s\n' "$out" >&2
  echo "  FAIL: $TEMPLATE does not parse" >&2
  exit 1
fi
[ -z "$out" ] || printf '%s\n' "$out"
echo "  ok:   template parses"

nevr=$(rpmspec -q --srpm --qf '%{name} %{version}-%{release}\n' "$spec" 2>/dev/null)
echo "  ok:   source package would be $nevr"

subpkgs=$(rpmspec -q --qf '%{name}\n' "$spec" 2>/dev/null | sort -u | tr '\n' ' ')
echo "  ok:   binary packages: $subpkgs"

echo "all checks passed"
