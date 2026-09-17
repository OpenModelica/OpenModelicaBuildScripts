# OpenModelicaBuildScripts

Scripts that build the OpenModelica Linux packages.

The packages are built with CMake and CPack, straight from a git checkout of
[OpenModelica](https://github.com/OpenModelica/OpenModelica). There are no source
packages any more: no `.dsc`, no `debian/rules`, no RPM spec. The jobs that run these
scripts live in the private [apt-build](https://gitlab.liu.se/OpenModelica/apt-build)
repository and run on the OpenModelica Jenkins.

Windows build scripts are at
[OpenModelicaSetup](https://github.com/OpenModelica/OpenModelicaSetup/).

## Layout

| Path                                        | What it is                                                           |
| ------------------------------------------- | -------------------------------------------------------------------- |
| [`cpack/`](./cpack)                         | Build the `.deb`/`.rpm` packages, and test them in a clean container |
| [`macports/`](./macports)                   | Portfile templates for macOS                                         |
| [`docker/`](./docker)                       | Dockerfiles for older images; build images come from [build-deps]    |
| [`.github/workflows/`](./.github/workflows) | CI, see [below](#ci)                                                 |

[build-deps]: https://github.com/OpenModelica/build-deps

## How the packages are defined

**What goes into which package is defined in the OpenModelica repository**, in
[`cmake/packaging/`](https://github.com/OpenModelica/OpenModelica/tree/master/cmake/packaging):

* `components.cmake` — the CPack components, one package each (`omc`, `simrt`,
  `omedit`, `omlibrary`, …), and the dependencies between them.
* `OpenModelicaCPackOptions.in.cmake` — the settings per package format: version,
  Debian `Depends:` (worked out by `dpkg-shlibdeps`, plus the toolchain omc runs to
  compile a model), RPM settings, NSIS.

It lives there, and not here, so that one definition serves every format CPack
produces, including the Windows installer. See section 8 of
[`README.cmake.md`](https://github.com/OpenModelica/OpenModelica/blob/master/README.cmake.md)
for what is packed.

This repository decides only how OpenModelica is *built* for a package: which
features are on, which compiler and which Qt it uses.

## Building packages

[`cpack/build-packages.sh`](./cpack/build-packages.sh) configures, builds and installs
OpenModelica, downloads the Modelica library cache, and runs `cpack`:

```bash
cpack/build-packages.sh -G DEB -o packages /path/to/OpenModelica
```

It needs

* **a git checkout with its tags.** The package version is derived from
  `git describe`; a shallow clone or one without tags has no version, and the script
  stops before building rather than after. In a container, a checkout owned by
  another user also needs `git config --global --add safe.directory '*'`.
* **the build dependencies of the distribution it runs on.** Use the matching
  `ghcr.io/openmodelica/build-deps:<os>-<version>` image, e.g. `ubuntu-24.04`.
  A package only installs on the distribution it was built for.
* **network access**, for the library cache. `--no-omlibrary` skips it and leaves the
  `omlibrary` package out.

The build choices it makes, all of which can be overridden by passing CMake flags
after `--`:

| Choice                      | Default                                              |
| --------------------------- | ---------------------------------------------------- |
| Compiler                    | clang if installed (set `CC`/`CXX` to change)        |
| Qt                          | 6 where Qt 6 WebEngine is installed, otherwise 5     |
| C++ simulation runtime      | on, except on armhf                                  |
| Testsuite                   | off (it would put `omc-diff` into the `omc` package) |
| GUI clients, OMSimulator    | on                                                   |
| OMOptim, encryption, ccache | off                                                  |

For example, a quicker local build that reuses ccache and packs only the compiler and
runtime:

```bash
cpack/build-packages.sh -G DEB --no-omlibrary \
  --cpack-arg -DCPACK_COMPONENTS_ALL="omc;simrt" \
  /path/to/OpenModelica -- -DOM_USE_CCACHE=ON
```

See `cpack/build-packages.sh --help` for all options.

## Testing packages

[`cpack/test-packages.sh`](./cpack/test-packages.sh) installs packages into a clean
system and compiles and simulates a model:

```bash
docker run --rm -v "$PWD:/work:ro" ubuntu:24.04 \
  /work/cpack/test-packages.sh /work/packages
```

It serves the packages from a local apt (or dnf) repository and installs only
`openmodelica-omc` from it, so the dependencies *between* the OpenModelica packages are
resolved the way a user's package manager resolves them. Installing the files by name,
or with `dpkg -i`, hides a missing inter-package dependency — that is how an `omc` that
could not find the simulation runtime's headers once went unnoticed. Name other
packages as extra arguments.

## CI

### Fast checks — [`packaging.yml`](./.github/workflows/packaging.yml)

`shellcheck` on the scripts in `cpack/`, on every pull request and push to `master`.

### Full build — [`build-packages.yml`](./.github/workflows/build-packages.yml)

Builds the Debian packages from an OpenModelica checkout in the `ubuntu-24.04`
build-deps image with `build-packages.sh`, then runs `test-packages.sh` on them in a
clean `ubuntu:24.04` container, and uploads the `.deb` files as an artifact. It is the
only job that proves the packages install and work.

It compiles everything, so it takes hours, and it never starts on its own. Run it via
`workflow_dispatch` (with an input to pick the OpenModelica ref), or put the
**`CI/Full Debian Packaging`** label on a pull request — it then runs for that pull
request, and again on every push to it, until the label comes off.

> [!IMPORTANT]
> One distribution, one architecture. Whether the packages build and work on the rest
> of the matrix, or on armhf and arm64, is still Jenkins' job.

## Migrating from the source packages

Until commit `1a86e5b` this repository held a `debian/` directory and an RPM spec that
built the packages from a source package with debhelper and rpmbuild. What those did
that the CPack definition in OpenModelica has not taken over yet:

| Old                                                   | Still needed in OpenModelica                                                                                    |
| ----------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| 20 binary packages (`omc`, `libomc`, `omc-common`, …) | `Provides:`/`Replaces:` from the old names, so upgrades do not strand anyone, and an `openmodelica` metapackage |
| Installed under `/usr`                                | `CPACK_PACKAGING_INSTALL_PREFIX` is still `/usr/local` for DEB                                                  |
| `debian/desktops/*.desktop`                           | `install()` rules into `share/applications`                                                                     |
| `debian/omnotebook.sharedmimeinfo`                    | an `install()` rule into `share/mime/packages`                                                                  |
| `debian/copyright`                                    | a `copyright` file in every package's `share/doc/<package>`                                                     |
| `debian/testmodels/flat_dcmotor.mos`                  | an `install()` rule into `share/doc/omc/testmodels`                                                             |
| `dh_strip`                                            | `CPACK_STRIP_FILES`, and `CPACK_DEBIAN_DEBUGINFO_PACKAGE` for the `-dbgsym` packages                            |

On the RPM side the spec built one `openmodelica-<branch>` package installed into
`/opt/openmodelica-<branch>`, with `update-alternatives` for `omc-<branch>`, so several
branches could be installed side by side. The CPack RPM layout needs that too, or a
decision to drop it.

Deliberately *not* carried over, because nothing uses them any more: the Debian menu
files and their `.xpm` icons (the menu system is retired), `omc.prerm` (it removed
alternatives for `omc-rml` and `omc-bootstrapped`), `OMEdit.sh` (a Qt 4.7 workaround),
`README.Debian`, and the standalone `OMPlot`, `OMOptim` and `OpenModelica-doc` source
packages that no pipeline built.

To look at any of them: `git show 1a86e5b:debian/<file>`.

## Docker Images

The images OpenModelica is built in, `build-deps`, come from the
[build-deps] repository, whose CI builds them for each distribution and publishes them to
`ghcr.io/openmodelica/build-deps` and `docker.openmodelica.org/build-deps`. They used to
be built by hand from `Dockerfile.build-deps*` here.

The Dockerfiles still in [`docker/`](./docker) are for other, older images. Each has a
script next to it that builds and pushes it, e.g. [`nightly.sh`](./docker/nightly.sh)
for [`Dockerfile.nightly`](./docker/Dockerfile.nightly).
