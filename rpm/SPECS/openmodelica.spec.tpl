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

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
%{summary}

%prep

%setup -q -n openmodelica_%{version}

autoconf
./configure CFLAGS="-Os" CXXFLAGS="-Os" QTDIR=/usr/%{_lib}/qt5/ --with-omniORB --without-cppruntime --without-omc --prefix=/opt/%{name} --without-omlibrary

%build

make -j8

%install
rm -rf %{buildroot}
make install DESTDIR="%{buildroot}"
mkdir -p %{buildroot}/opt/%{name}/lib/
ln -s /usr/lib/omlibrary %{buildroot}/opt/%{name}/lib/

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
/opt/%{name}/*

%changelog
* DATE  OpenModelica <openmodelica@ida.liu.se> ${version}-1
- First Build
