#!/bin/sh
# Static validation of the debian/ packaging metadata in this repository.
#
# A real package build compiles all of OpenModelica and takes hours, so the
# nightly Jenkins job is the only place the packaging is exercised end to end.
# This script checks what can be checked in seconds: that the control files
# parse, that debhelper accepts the declared compatibility level on this
# distribution, that debian/rules only calls helpers that still exist and only
# passes options that still exist at that compat level, and that every
# debian/<package>.<helper> file belongs to a binary package we build.
#
# It does NOT catch a .install glob that stopped matching because upstream moved
# a file; only a real build does that.
#
# Run it from the top of the repository, inside a distribution we ship for:
#
#   docker run --rm -v "$PWD:/src" -w /src ubuntu:24.04 sh -c \
#     'apt-get update -qq && apt-get install -qy --no-install-recommends \
#      debhelper dpkg-dev && .ci/check-debian-packaging.sh'

set -eu

# Keep in sync with the compat level declared in the control files.
EXPECTED_COMPAT=13

TREES="debian OMPlot/debian OMOptim/debian OpenModelica-doc/debian"

# debhelper config files named debian/<binary package>.<suffix>.  A typo in the
# package part makes debhelper ignore the file without a word, and the package
# then ships empty, so the package name has to exist in debian/control.
PKG_SUFFIXES="install docs dirs links examples manpages menu menu-method info
 init service tmpfiles sharedmimeinfo lintian-overrides preinst postinst prerm
 postrm triggers README.Debian NEWS"

# Command/option combinations debhelper has removed.  The compat level each was
# dropped in is listed in debhelper-compat-upgrade-checklist(7); add a line here
# when a helper we call loses an option we pass.
# Fields: helper:option:compat level that removed it:what to use instead
removed_usage() {
  cat <<'REMOVED'
dh_install:--list-missing:12:dh_missing --list-missing
dh_install:--fail-missing:12:dh_missing --fail-missing
dh_clean:-k:12:dh_prep
dh_installinit:--no-restart-on-upgrade:12:--no-stop-on-upgrade
REMOVED
}

status=0
fail() { echo "  FAIL: $*" >&2; status=1; }
ok()   { echo "  ok:   $*"; }

command -v dh_assistant >/dev/null 2>&1 || {
  echo "dh_assistant not found; this script needs debhelper >= 13.5" >&2
  exit 2
}

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

echo "debhelper $(dpkg-query -f '${Version}' -W debhelper) on $(. /etc/os-release; echo "$PRETTY_NAME")"

for tree in $TREES; do
  echo "== $tree"
  work="$scratch/$(echo "$tree" | tr / _)"
  mkdir -p "$work"
  cp -a "$tree" "$work/debian"

  # debian/changelog is a template.  The source-package job fills it in the same
  # way (see update-source-repo.py and make-packages.py in the apt-build repo).
  sed -i -e 's/@REV@/1.0.0~dev-0-g0000000/' -e 's/@DISTS@/unstable/' \
    -e "s/@TIME@/$(date -R)/" "$work/debian/changelog"

  if [ -e "$work/debian/compat" ]; then
    fail "debian/compat still exists; the compat level belongs in Build-Depends: debhelper-compat"
  else
    ok "no stale debian/compat"
  fi

  if ! (
    cd "$work" || exit 1

    if ! changelog=$(dpkg-parsechangelog 2>&1); then
      printf '%s\n' "$changelog" >&2
      echo "  FAIL: debian/changelog does not parse" >&2
      exit 1
    fi
    echo "  ok:   changelog parses ($(printf '%s\n' "$changelog" | sed -n 's/^Source: //p')" \
         "$(printf '%s\n' "$changelog" | sed -n 's/^Version: //p'))"

    if ! perl -MDpkg::Control::Info -e '
           my $c = Dpkg::Control::Info->new("debian/control");
           print $_->{Package}, "\n" for $c->get_packages();
         ' > packages.txt 2> control.err; then
      cat control.err >&2
      echo "  FAIL: debian/control does not parse" >&2
      exit 1
    fi
    if ! [ -s packages.txt ]; then
      echo "  FAIL: debian/control declares no binary packages" >&2
      exit 1
    fi
    echo "  ok:   control parses ($(wc -l < packages.txt | tr -d ' ') binary packages)"

    # The check that catches a mis-declared compat level: debhelper accepts only
    # "debhelper-compat (= N)", and errors out if this distribution's debhelper
    # does not support N.
    if ! compat=$(dh_assistant active-compat-level 2>&1); then
      printf '%s\n' "$compat" >&2
      echo "  FAIL: debhelper rejects the declared compatibility level" >&2
      exit 1
    fi
    compat=$(printf '%s\n' "$compat" | sed -n 's/.*"active-compat-level":\([0-9]*\).*/\1/p')
    if [ "$compat" != "$EXPECTED_COMPAT" ]; then
      echo "  FAIL: active compat level is '$compat', expected $EXPECTED_COMPAT" >&2
      exit 1
    fi
    echo "  ok:   compat level $compat"
  ); then
    status=1
    continue
  fi

  packages="$work/packages.txt"

  # Every helper debian/rules calls has to still ship in this debhelper.
  sed -e 's/#.*//' "$tree/rules" > "$work/rules.uncommented"
  missing=""
  for helper in $(grep -o 'dh_[a-z0-9_]*' "$work/rules.uncommented" | sort -u); do
    command -v "$helper" >/dev/null 2>&1 || missing="$missing $helper"
  done
  if [ -n "$missing" ]; then
    fail "debian/rules calls helpers that no longer exist:$missing"
  else
    ok "every dh_* helper called by debian/rules exists"
  fi

  # ... and must not pass options removed at or below our compat level.
  removed=""
  removed_usage > "$work/removed-usage"
  while IFS=: read -r cmd opt gone use; do
    [ -n "$cmd" ] || continue
    [ "$EXPECTED_COMPAT" -ge "$gone" ] || continue
    if grep -q -- "$cmd[^&|;]*[[:space:]]$opt\\b" "$work/rules.uncommented"; then
      removed="$removed
          $cmd $opt (gone in compat $gone; use: $use)"
    fi
  done < "$work/removed-usage"
  if [ -n "$removed" ]; then
    fail "debian/rules uses debhelper options removed at compat $EXPECTED_COMPAT:$removed"
  else
    ok "no debhelper options removed at compat $EXPECTED_COMPAT"
  fi

  orphans=""
  for f in "$tree"/*; do
    [ -f "$f" ] || continue
    base=${f##*/}
    for suffix in $PKG_SUFFIXES; do
      case "$base" in
        *".$suffix")
          pkg=${base%".$suffix"}
          grep -qx "$pkg" "$packages" || orphans="$orphans $base"
          ;;
      esac
    done
  done
  if [ -n "$orphans" ]; then
    fail "config files naming a package that is not in debian/control:$orphans"
  else
    ok "every debian/<package>.<helper> file matches a binary package"
  fi
done

[ $status -eq 0 ] && echo "all checks passed"
exit $status
