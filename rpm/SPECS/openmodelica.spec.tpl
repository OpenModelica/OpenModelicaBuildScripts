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
PATCHES
URL: https://openmodelica.org/

# Recommended (for the repo): git rpm-build rpmdevtools epel-release
%if 0%{?rhel} > 0
# CentOS / RHEL requires the EPEL repository (for omniORB, etc)
BuildRequires: epel-release
Requires: epel-release
%endif
BuildRequires: automake
BuildRequires: omniORB-devel
BuildRequires: expat-devel
BuildRequires: lapack-devel
BuildRequires: libtool
BuildRequires: uuid-devel
BuildRequires: hdf5-devel
BuildRequires: boost-devel
BuildRequires: hwloc-devel
BuildRequires: readline-devel
BuildRequires: gettext
BuildRequires: cmake
BuildRequires: java
BuildRequires: tar
BuildRequires: xz
BuildRequires: gcc
BuildRequires: gcc-gfortran
BuildRequires: gcc-c++
BuildRequires: qt5-linguist
BuildRequires: qt5-qttools
BuildRequires: qt5-qtbase-devel
BuildRequires: qt5-qtsvg-devel
%if 0%{?rhel} >= 7
BuildRequires: qt5-qt3d-devel
%endif
BuildRequires: qt5-qtwebkit-devel
BuildRequires: qt5-qtxmlpatterns-devel
BuildRequires: lpsolve-devel

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
%else
Requires: omlib-all
%endif

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
%{summary}

%prep

%setup -q -n openmodelica_DEBVERSION

PATCHCMDS

autoconf
./configure CFLAGS="-Os" CXXFLAGS="-Os" QTDIR=/usr/%{_lib}/qt5/ --with-omniORB CONFIGUREFLAGS --without-omc --prefix=/opt/%{name} --without-omlibrary

%build

make -j8

%install
rm -rf %{buildroot}
make install DESTDIR="%{buildroot}"
mkdir -p %{buildroot}/opt/%{name}/lib/ %{buildroot}%{_bindir}
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

%ghost %{_bindir}/omc
%ghost %{_bindir}/OMEdit
%ghost %{_bindir}/OMShell
%ghost %{_bindir}/OMShell-terminal
%ghost %{_bindir}/OMNotebook
%ghost %{_bindir}/OMPlot

%changelog
* DATE  OpenModelica <openmodelica@ida.liu.se> ${version}-1
- First Build
