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

%if 0%{?rhel} == 6
Autoreq: 0
Requires: readline
Requires: qt5-qtbase
Requires: qt5-qtsvg
Requires: qt5-qtwebkit
Requires: qt5-qtxmlpatterns
%endif
Autoprov: 0
Prefix: /opt/%{name}
Prefix: %{_bindir}

%global __requires_exclude ^(PRIVATELIBS)$

# Recommended (for the repo): git rpm-build rpmdevtools epel-release
%if 0%{?rhel} > 0
# CentOS / RHEL requires the EPEL repository (for omniORB, etc)
BuildRequires: epel-release
Requires: epel-release
%endif

Requires: lapack-devel
Requires: make
Requires: gcc
Requires: gcc-gfortran
Requires: gcc-c++

BuildRequires: automake
%if 0%{?rhel} >= 8
%define withomniorb --without-omniORB
%else
%define withomniorb --with-omniORB
BuildRequires: omniORB-devel
BuildRequires: lpsolve-devel
%endif
BuildRequires: expat-devel
BuildRequires: bison
BuildRequires: flex
BuildRequires: lapack-devel
BuildRequires: libtool
BuildRequires: uuid-devel
BuildRequires: hdf5-devel
BuildRequires: boost-devel
BuildRequires: boost-static
BuildRequires: hwloc-devel
BuildRequires: readline-devel
BuildRequires: curl-devel
BuildRequires: gettext
BuildRequires: cmake
BuildRequires: make
BuildRequires: java
BuildRequires: tar
BuildRequires: xz
BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: gcc-gfortran
BuildRequires: qt5-qtwebkit-devel
BuildRequires: qt5-linguist
BuildRequires: qt5-qttools
BuildRequires: qt5-qtbase-devel
BuildRequires: qt5-qtsvg-devel
BuildRequires: uuid-devel
%if 0%{?rhel} >= 7
BuildRequires: qt5-qt3d-devel
%endif
BuildRequires: qt5-qtxmlpatterns-devel

# EL6 has -static-libstdc++ inside devtools (but the system g++ doesn't know the flag)
%{?el6:Requires: devtoolset-8-gcc}
%{?el6:Requires: devtoolset-8-gcc-c++}
%{?el6:Requires: devtoolset-8-gcc-gfortran}
%{?!el6:BuildRequires: libstdc++-static}
%{?!el6:Requires: libstdc++-static}

# EL7 has -static-libstdc++ inside devtools (but the system g++ doesn't know the flag) -- adrpo: check this, also for el6
%{?el7:Requires: devtoolset-8-gcc}
%{?el7:Requires: devtoolset-8-gcc-c++}
%{?el7:Requires: devtoolset-8-gcc-gfortran}
%{?!el7:BuildRequires: libstdc++-static}
%{?!el7:Requires: libstdc++-static}

%if 0%{?rhel} <= 7 && 0%{?rhel} >= 1
BuildRequires: devtoolset-8-gcc devtoolset-8-gcc-c++ devtoolset-8-gcc-gfortran
%define devtoolsconfigureflags CC=/opt/rh/devtoolset-8/root/usr/bin/gcc CXX=/opt/rh/devtoolset-8/root/usr/bin/g++ FC=/opt/rh/devtoolset-8/root/usr/bin/gfortran
%endif

%if 0%{?fedora} >= 25
BuildRequires: OpenSceneGraph-devel
%endif

# We should use clang, but OMEdit doesn't compile with it due to odd default qmake flags
Requires: gcc
Requires: gcc-c++
Requires: lapack-devel

Requires(post): %{_sbindir}/update-alternatives
Requires(postun): %{_sbindir}/update-alternatives

# CentOS doesn't have suggests
%if 0%{?fedora} >= 24
Suggests: omlib-all
Suggests: boost-devel
Suggests: boost-static
%else
Requires: omlib-all
Requires: boost-devel
Requires: boost-static
%endif

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
%{summary}

%prep

%setup -q -n openmodelica_DEBVERSION
tar xJf %{_sourcedir}/openmodelica-doc-DOCUMENTATIONVERSION.tar.xz

PATCHCMDS

%if 0%{?rhel} <= 7 && 0%{?rhel} >= 1
source /opt/rh/devtoolset-8/enable
%endif
autoconf
./configure CFLAGS="-Os" CXXFLAGS="-Os" QTDIR=/usr/%{_lib}/qt5/ %{withomniorb} CONFIGUREFLAGS %{?devtoolsconfigureflags} --without-omc --prefix=/opt/%{name} --without-omlibrary

%build

make -j8

%install
rm -rf %{buildroot}
make install DESTDIR="%{buildroot}"
mkdir -p %{buildroot}/opt/%{name}/lib/ %{buildroot}/opt/%{name}/share/doc/omc/ %{buildroot}%{_bindir}
ln -s /usr/lib/omlibrary %{buildroot}/opt/%{name}/lib/
ln -s /opt/%{name}/bin/omc %{buildroot}%{_bindir}/omc-BRANCH
ln -s /opt/%{name}/bin/OMEdit %{buildroot}%{_bindir}/OMEdit-BRANCH
ln -s /opt/%{name}/bin/OMShell %{buildroot}%{_bindir}/OMShell-BRANCH
ln -s /opt/%{name}/bin/OMShell-terminal %{buildroot}%{_bindir}/OMShell-terminal-BRANCH
ln -s /opt/%{name}/bin/OMNotebook %{buildroot}%{_bindir}/OMNotebook-BRANCH
ln -s /opt/%{name}/bin/OMPlot %{buildroot}%{_bindir}/OMPlot-BRANCH
touch %{buildroot}%{_bindir}/omc
touch %{buildroot}%{_bindir}/OMEdit
touch %{buildroot}%{_bindir}/OMShell
touch %{buildroot}%{_bindir}/OMShell-terminal
touch %{buildroot}%{_bindir}/OMNotebook
touch %{buildroot}%{_bindir}/OMPlot
cp -a openmodelica-doc*/* %{buildroot}/opt/%{name}/share/doc/omc/

%postun
if [ "$1" -ge "1" ]; then
  if [ "`readlink %{_sysconfdir}/alternatives/openmodelica`" == "%{_bindir}/omc-BRANCH" ]; then
    %{_sbindir}/alternatives --set openmodelica %{_bindir}/omc-BRANCH
  fi
fi

%post
%{_sbindir}/update-alternatives --install %{_bindir}/omc openmodelica %{_bindir}/omc-BRANCH PRIORITY \
  --slave %{_bindir}/OMEdit openmodelica-OMEdit %{_bindir}/OMEdit-BRANCH \
  --slave %{_bindir}/OMShell openmodelica-OMShell %{_bindir}/OMShell-BRANCH \
  --slave %{_bindir}/OMShell-terminal openmodelica-OMShell-terminal %{_bindir}/OMShell-terminal-BRANCH \
  --slave %{_bindir}/OMNotebook openmodelica-OMNotebook %{_bindir}/OMNotebook-BRANCH \
  --slave %{_bindir}/OMPlot openmodelica-OMPlot %{_bindir}/OMPlot-BRANCH

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
%ghost %{_bindir}/OMEdit
%ghost %{_bindir}/OMShell
%ghost %{_bindir}/OMShell-terminal
%ghost %{_bindir}/OMNotebook
%ghost %{_bindir}/OMPlot

%changelog
* DATE  OpenModelica <openmodelica@ida.liu.se> ${version}-1
- First Build
