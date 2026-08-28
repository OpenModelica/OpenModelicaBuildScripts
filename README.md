# OpenModelicaBuildScripts

A collection of scripts that can build OpenModelica packages on miscellaneous platforms.

Nothing here builds OpenModelica on its own. This repository holds the
*packaging metadata*; the jobs that use it live in the private
[apt-build](gitlab.liu.se/OpenModelica/apt-build) repository and run on the
OpenModelica Jenkins.

Windows build scripts are at
[OpenModelicaSetup](https://github.com/OpenModelica/OpenModelicaSetup/).

## Layout

| Path | What it is |
| --- | --- |
| [`debian/`](./debian) | Debian/Ubuntu packaging for the `openmodelica` source package — the one the nightly builds use |
| [`OMPlot/debian/`](./OMPlot/debian), [`OMOptim/debian/`](./OMOptim/debian), [`OpenModelica-doc/debian/`](./OpenModelica-doc/debian) | Older standalone source packages, kept but not built by the current pipeline |
| [`rpm/`](./rpm) | Spec template and patches for the Fedora/EL packages |
| [`macports/`](./macports) | Portfile templates for macOS |
| [`docker/`](./docker) | Dockerfiles for the `build-deps` images on docker.openmodelica.org |
| [`.ci/`](./.ci) | The checks GitHub Actions runs on every pull request |

`OpenModelica/debian` is a symlink to the top-level [`debian/`](./debian), so every
source project has its packaging under `<project>/debian`.

## Debian packaging

### How `debian/` becomes a package

`debian/` is never built where it sits. The nightly pipeline does roughly this:

1. **Source package** — `update-source-repo.py` (apt-build) archives the OpenModelica
   git tree, drops the testsuite and documentation directories, and copies this repository's
   `debian/` in as `openmodelica_<rev>/debian`. It substitutes `@REV@` and `@TIME@` in
   [`debian/changelog`](./debian/changelog) and runs `debuild -S`. The resulting
   `.dsc` / `.orig.tar.xz` / `.debian.tar.xz` are published to
   <https://build.openmodelica.org/apt/pool/contrib/>.
   The branch taken from this repository is `master` unless `projects.json` pins a
   `release-buildscriptbranch` / `stable-buildscriptbranch`.
2. **Binary packages** — the main Jenkins job downloads that `.dsc` into
   `docker.openmodelica.org/build-deps:<codename>.nightly.<arch>` and runs
   `dpkg-buildpackage -rfakeroot -b`. That compiles all of OpenModelica, so a full
   build takes hours.

The distributions and architectures built are listed in
`current-linux-os-releases.json` in apt-build. At the time of writing that is
jammy, noble, resolute and trixie on amd64, armhf and arm64.

### What is in `debian/`

* [`control`](./debian/control) — one source stanza and 20 binary packages (`omc`,
  `libomc`, `omedit`, `omshell`, `omnotebook`, `omsimulator`, `omlibrary`, …). The
  build dependencies carry alternatives (`libqt5webkit5-dev | qtwebengine5-dev`)
  because a single control file has to satisfy every distribution in the matrix.
* [`rules`](./debian/rules) — a hand-written rules file, *not* the `dh` sequencer. It
  configures and builds the tree itself and then calls each `dh_*` helper explicitly
  from the `install` and `binary-arch` targets. There are no override targets; edit the
  recipes directly.
* `<package>.install` — the file lists. Everything is installed into `debian/tmp` by
  `make install DESTDIR=…` first, and these files distribute it into the binary
  packages. Paths are globs, e.g.
  `debian/tmp/usr/lib/*/omc/libOMSimulator.so`.
* Desktop integration: [`desktops/`](./debian/desktops), [`icons/`](./debian/icons),
  `*.menu`, `omnotebook.sharedmimeinfo`.
* The debhelper compatibility level is declared as `debhelper-compat (= 13)` in
  `Build-Depends`.

### What usually breaks it

* **An `.install` glob stops matching.** When upstream moves or stops building a file,
  `dh_install` fails with `Cannot find (any matches for) …` / `missing files, aborting`
  and the whole nightly build dies. This is the most common breakage — see the history
  of [`libomsimulator.install`](./debian/libomsimulator.install).
* **A helper or option is retired.** Every distribution upgrade brings a newer
  debhelper; raising the compat level can remove an option `rules` passes. See
  `debhelper-compat-upgrade-checklist(7)`.
* **A typo in a config file name.** `debian/<package>.install` where `<package>` is not
  in `control` is ignored silently, and the package ships empty.

The first one can only be caught by a real build; [`.ci/`](./.ci) catches the other two.

### Testing a packaging change

The metadata checks run in seconds:

```bash
docker run --rm -v "$PWD:/src" -w /src ubuntu:noble sh -c \
  'apt-get update -qq && apt-get install -qy --no-install-recommends debhelper dpkg-dev \
   && .ci/check-debian-packaging.sh'
```

For a real build, reuse the last published source package and swap in your `debian/`:

```bash
V=1.28.0~dev-489-gda9d1ce   # a version from build.openmodelica.org/apt/pool/contrib/
docker run --rm -it -v "$PWD:/buildscripts" \
  docker.openmodelica.org/build-deps:jammy.nightly.amd64 bash
cd /tmp
for e in -1.dsc -1.debian.tar.xz .orig.tar.xz; do
  wget -q "https://build.openmodelica.org/apt/pool/contrib/openmodelica_$V$e"
done
dpkg-source -x "openmodelica_$V-1.dsc"
rm -rf "openmodelica-$V/debian" && cp -a /buildscripts/debian "openmodelica-$V/debian"
sed -i -e "s/@REV@/$V/" -e "s/@TIME@/$(date -R)/" "openmodelica-$V/debian/changelog"
cd "openmodelica-$V" && dpkg-buildpackage -rfakeroot -b -j"$(nproc)"
```

The first run takes hours. Afterwards `build-stamp` is cached, so re-running only
`fakeroot debian/rules binary-arch` after another `debian/` tweak takes minutes.

Or trigger the [`full deb build`](./.github/workflows/build-deb.yml) workflow, which does
the same thing on a runner.

## RPM packaging

[`rpm/SPECS/openmodelica.spec.tpl`](./rpm/SPECS/openmodelica.spec.tpl) is a template,
not a valid spec file. The Jenkins job replaces upper-case placeholders (`NAME`,
`RPMVERSION`, `DEBVERSION`, `RELEASENUM`, `PATCHES`, `PRIVATELIBS`, `DATE`, …) with
values from `projects.json` before calling `rpmbuild`, and copies
[`rpm/PATCHES/`](./rpm/PATCHES) into `SOURCES`. Because the substitution is a plain
string replace, any occurrence of those words anywhere in the file is replaced.

Targets at the time of writing: el8, el9, el10, fc43 and fc44.

## CI

Two workflows, split by how long they take.

### Fast checks — [`packaging.yml`](./.github/workflows/packaging.yml)

Runs two jobs on every pull request and on pushes to `master`. Neither builds anything;
they check that the packaging metadata is well formed and that every distribution we
ship for still accepts it, which is what silently rots between releases.

| Job | Script | Runs on |
| --- | --- | --- |
| `debian` | [`.ci/check-debian-packaging.sh`](./.ci/check-debian-packaging.sh) | `ubuntu:jammy`, `ubuntu:noble`, `ubuntu:resolute`, `debian:trixie` |
| `rpm` | [`.ci/check-rpm-spec.sh`](./.ci/check-rpm-spec.sh) | `almalinux:8`, `almalinux:9`, `almalinux:10`, `fedora:43`, `fedora:44` |

`check-debian-packaging.sh` checks, for each of the four `debian/` trees, that
`control` and the templated `changelog` parse, that no stale `debian/compat` is left
behind, that debhelper on that distribution accepts the declared compatibility level,
that every `dh_*` command `rules` calls still exists and is passed no option removed at
that compat level, and that every `debian/<package>.<helper>` file names a real binary
package.

`check-rpm-spec.sh` performs the same placeholder substitution the Jenkins job does and
has `rpmspec` parse the result, which catches spec syntax mistakes — a missing `%`, an
empty `%define`, a stray comment.

Both scripts are plain `/bin/sh` and take no arguments; run them from the top of the
repository as shown in their header comments. The image lists mirror
`current-linux-os-releases.json` in apt-build — update them when a distribution is
added or goes EOL, and update `EXPECTED_COMPAT` in `check-debian-packaging.sh` whenever
the compat level in the control files changes.

### Full build — [`build-deb.yml`](./.github/workflows/build-deb.yml)

Builds OpenModelica from a git checkout with the Autoconf + Makefile build and then runs
`dpkg-buildpackage` against this repository's `debian/`, the same sequence Jenkins uses,
and uploads the resulting `.deb` files as an artifact. It is the only job that catches a
`.install` glob that stopped matching, and the only one that proves the `Build-Depends`
are still installable.

It compiles everything, so it takes hours. It runs weekly, on demand via
`workflow_dispatch` (with an input to pick the OpenModelica ref), and on pull requests
that touch `debian/`. Only on `ubuntu-latest` — Jenkins covers the rest of the matrix.

It uses the Autoconf + Makefile build; switching it to the CMake build is a later change.

> [!IMPORTANT]
> What no CI here tells you: whether the packages build on the other distributions
> in the matrix, or on armhf and arm64. That is still Jenkins' job.

## Docker Images

Docker images are hosted on [docker.openmodelica.org](docker.openmodelica.org) and need to
be uploaded manually.

### Example

To add a new image to [docker.openmodelica.org](docker.openmodelica.org)
the image needs to be build, tagged correctly and then pushed to the server.

For example for [Dockerfile.build-deps-cmake-1.16.3](./docker/Dockerfile.build-deps-cmake-1.16.3)
one would run:

```bash
docker build --tag build-deps-cmake:v1.16.3 -f Dockerfile.build-deps-cmake-1.16.3 .
docker tag build-deps-cmake:v1.16.3 docker.openmodelica.org/build-deps-cmake:v1.16.3
docker push docker.openmodelica.org/build-deps-cmake:v1.16.3
```
