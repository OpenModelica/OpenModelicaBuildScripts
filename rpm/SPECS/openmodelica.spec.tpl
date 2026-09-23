# See also Jenkinsfile in apt-build repository for stuff that is installed BEFORE everything here
# Don't try fancy stuff like debuginfo, which is useless on binary-only
# packages. Don't strip binary too
# Be sure buildpolicy set to do nothing
%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress

Summary: OpenModelica
Name: NAME
Version: RPMVERSION
Release: RELEASENUM%{?dist}
License: OSMC-PL
Group: Development/Tools
# spectool -g -R SPECS/xxx.spec
# sudo yum-builddep SPECS/xxx.spec
SOURCE0 : https://build.openmodelica.org/apt/pool/contrib/openmodelica_DEBVERSION.orig.tar.xz
SOURCE1 : https://openmodelica.org/doc/openmodelica-doc-DOCUMENTATIONVERSION.tar.xz
PATCHES
URL: https://openmodelica.org/

Autoprov: 0
Prefix: /opt/%{name}
Prefix: %{_bindir}

%global __requires_exclude ^(PRIVATELIBS)$

# Recommended (for the repo): git rpm-build rpmdevtools epel-release
%if 0%{?rhel} > 0
# CentOS / RHEL requires the EPEL repository
BuildRequires: epel-release
Requires: epel-release
%endif

Requires: lapack-devel
Requires: make
Requires: gcc
Requires: gcc-gfortran
Requires: gcc-c++

BuildRequires: expat-devel
BuildRequires: autoconf
BuildRequires: bison
BuildRequires: flex
BuildRequires: lapack-devel
BuildRequires: uuid
BuildRequires: uuid-devel
BuildRequires: libuuid-devel
BuildRequires: hdf5-devel
BuildRequires: boost-devel
BuildRequires: boost-static
BuildRequires: hwloc-devel
BuildRequires: readline-devel
BuildRequires: libffi-devel
BuildRequires: curl-devel
BuildRequires: gettext
BuildRequires: make
BuildRequires: java
BuildRequires: tar
BuildRequires: xz
BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: gcc-gfortran
# EL8 is the only target left without qt6, in EPEL or anywhere else, and the
# GUI clients no longer build against qt5: ship el8 without them.
%if 0%{?rhel} == 8
%define omnogui 1
%endif

%if ! 0%{?omnogui}
BuildRequires: qt6-qtwebengine-devel
BuildRequires: qt6-linguist
BuildRequires: qt6-qttools-devel
BuildRequires: qt6-qtbase-devel
BuildRequires: qt6-qtsvg-devel
BuildRequires: qt6-qt3d-devel
BuildRequires: qt6-qt5compat-devel
BuildRequires: qt6-qthttpserver-devel
BuildRequires: qt6-qtwebsockets-devel
BuildRequires: qt6-qtquick3d-devel
%endif

BuildRequires: cmake

# The base centos:8 image (we use for our build-deps:el8 image) comes with
# broken cmake package due to old libarchive (v3.3.2). v3.3.3 Seems to work.
# Once the base image is updated this can be removed.
%if 0%{?rhel} == 8
BuildRequires: libarchive >= 3.3.3
%endif

# EL8's system gcc is 8.5, too old to build with.
%{?el8:Requires: gcc-toolset-11-gcc gcc-toolset-11-gcc-c++ gcc-toolset-11-gcc-gfortran}
%if 0%{?rhel} == 8
BuildRequires: gcc-toolset-11-gcc gcc-toolset-11-gcc-c++ gcc-toolset-11-gcc-gfortran
%define devtoolscmakeflags -DCMAKE_C_COMPILER=/opt/rh/gcc-toolset-11/root/usr/bin/gcc -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-11/root/usr/bin/g++ -DCMAKE_Fortran_COMPILER=/opt/rh/gcc-toolset-11/root/usr/bin/gfortran
%endif

%if 0%{?omnogui}
%define omguicmakeflags -DOM_ENABLE_GUI_CLIENTS=OFF
%else
%define omguicmakeflags -DOM_ENABLE_GUI_CLIENTS=ON -DCMAKE_PREFIX_PATH=/usr/%{_lib}/qt6
%endif


Requires: gcc
Requires: gcc-c++
Requires: lapack-devel

Requires(post): %{_sbindir}/update-alternatives
Requires(postun): %{_sbindir}/update-alternatives

Suggests: boost-devel
Suggests: boost-static
Suggests: lapack-static
Suggests: openblas-static

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
%{summary}

%prep

%setup -q -n openmodelica_DEBVERSION
tar xJf %{_sourcedir}/openmodelica-doc-DOCUMENTATIONVERSION.tar.xz

PATCHCMDS

# The tarball has no git; CMake reads OMVERSION.txt.
echo 'vDEBVERSION' | tr '~' '-' > OMVERSION.txt

%build

%if 0%{?rhel} == 8
source /opt/rh/gcc-toolset-11/enable
%endif

export LANG=C.UTF-8
# CONFIGUREFLAGS: extra cmake -D arguments, from projects.json in apt-build.
cmake -S . -B build_rpm -Wno-dev \
  -DCMAKE_INSTALL_PREFIX=/opt/%{name} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS_RELEASE="-Os -DNDEBUG" \
  -DCMAKE_CXX_FLAGS_RELEASE="-Os -DNDEBUG" \
  -DOM_USE_CCACHE=OFF \
  -DOM_ENABLE_TESTSUITE=OFF \
  -DOM_ENABLE_DOCS=OFF \
  %{omguicmakeflags} \
  -DOM_ENABLE_OMSIMULATOR=ON \
  -DOM_OMOPTIM_ENABLE=OFF \
  -DOM_RUST_RESULT_READERS=ON \
  -DOM_RUST_RESULT_WRITERS=ON \
  -DOM_ENABLE_RUST_SIM_RUNTIME=ON \
  %{?devtoolscmakeflags} CONFIGUREFLAGS
cmake --build build_rpm --parallel 8

%install
rm -rf %{buildroot}
DESTDIR="%{buildroot}" cmake --install build_rpm
# An install rule with an absolute DESTINATION in the build tree (MUMPS, via
# moo/Ipopt.cmake) has DESTDIR mirror it into the buildroot; nothing belongs
# under the rpm build directory there.
rm -rf "%{buildroot}%{_builddir}"
# The cmake omlibrary target would download with an omc that is not installed yet.
if test -f libraries/install-index.json; then
  rm -rf omlibrary-download
  mkdir -p omlibrary-download/.openmodelica/libraries
  cp libraries/install-index.json omlibrary-download/.openmodelica/libraries/index.json
  (cd omlibrary-download && %{buildroot}/opt/%{name}/bin/omc ../libraries/install-index.mos)
  mkdir -p %{buildroot}/opt/%{name}/share/omlibrary/cache
  cp libraries/install-index.json %{buildroot}/opt/%{name}/share/omlibrary/cache/index.json
  cp omlibrary-download/.openmodelica/cache/* %{buildroot}/opt/%{name}/share/omlibrary/cache/
fi
mkdir -p %{buildroot}/opt/%{name}/lib/ %{buildroot}/opt/%{name}/share/doc/omc/ %{buildroot}%{_bindir}
ln -s /usr/lib/omlibrary %{buildroot}/opt/%{name}/lib/
ln -s /opt/%{name}/bin/omc %{buildroot}%{_bindir}/omc-BRANCH
touch %{buildroot}%{_bindir}/omc
%if ! 0%{?omnogui}
ln -s /opt/%{name}/bin/OMEdit %{buildroot}%{_bindir}/OMEdit-BRANCH
ln -s /opt/%{name}/bin/OMShell %{buildroot}%{_bindir}/OMShell-BRANCH
ln -s /opt/%{name}/bin/OMShell-terminal %{buildroot}%{_bindir}/OMShell-terminal-BRANCH
ln -s /opt/%{name}/bin/OMNotebook %{buildroot}%{_bindir}/OMNotebook-BRANCH
ln -s /opt/%{name}/bin/OMPlot %{buildroot}%{_bindir}/OMPlot-BRANCH
touch %{buildroot}%{_bindir}/OMEdit
touch %{buildroot}%{_bindir}/OMShell
touch %{buildroot}%{_bindir}/OMShell-terminal
touch %{buildroot}%{_bindir}/OMNotebook
touch %{buildroot}%{_bindir}/OMPlot
%endif
cp -a openmodelica-doc*/* %{buildroot}/opt/%{name}/share/doc/omc/

%postun
if [ "$1" -ge "1" ]; then
  if [ "`readlink %{_sysconfdir}/alternatives/openmodelica`" == "%{_bindir}/omc-BRANCH" ]; then
    %{_sbindir}/alternatives --set openmodelica %{_bindir}/omc-BRANCH
  fi
fi

%post
slaves=""
%if ! 0%{?omnogui}
slaves="--slave %{_bindir}/OMEdit openmodelica-OMEdit %{_bindir}/OMEdit-BRANCH \
  --slave %{_bindir}/OMShell openmodelica-OMShell %{_bindir}/OMShell-BRANCH \
  --slave %{_bindir}/OMShell-terminal openmodelica-OMShell-terminal %{_bindir}/OMShell-terminal-BRANCH \
  --slave %{_bindir}/OMNotebook openmodelica-OMNotebook %{_bindir}/OMNotebook-BRANCH \
  --slave %{_bindir}/OMPlot openmodelica-OMPlot %{_bindir}/OMPlot-BRANCH"
%endif
%{_sbindir}/update-alternatives --install %{_bindir}/omc openmodelica %{_bindir}/omc-BRANCH PRIORITY $slaves

%preun
if [ $1 = 0 ]; then
  %{_sbindir}/update-alternatives --remove openmodelica %{_bindir}/omc-BRANCH
fi

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
/opt/%{name}/*
%{_bindir}/*-BRANCH
%ghost %{_bindir}/omc
%if ! 0%{?omnogui}
%ghost %{_bindir}/OMEdit
%ghost %{_bindir}/OMShell
%ghost %{_bindir}/OMShell-terminal
%ghost %{_bindir}/OMNotebook
%ghost %{_bindir}/OMPlot
%endif

%changelog
* DATE  OpenModelica <openmodelica@ida.liu.se> ${version}-1
- First Build
