# Don't try fancy stuff like debuginfo, which is useless on binary-only
# packages. Don't strip binary too
# Be sure buildpolicy set to do nothing
%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress

Summary: OpenModelica
Name: openmodelica-BRANCH
Version: VERSION
Release: RELEASENUM
License: OSMC-PL
Group: Development/Tools
# spectool -g -R SPECS/xxx.spec
# sudo yum-builddep SPECS/xxx.spec
SOURCE0 : https://build.openmodelica.org/apt/pool/contrib/openmodelica_%{version}.orig.tar.xz
URL: https://openmodelica.org/

# Recommended (for the repo): git rpm-build rpmdevtools epel-release
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
BuildRequires: gcc
BuildRequires: gcc-gfortran
BuildRequires: gcc-c++
BuildRequires: qt5-linguist
BuildRequires: qt5-qttools
BuildRequires: qt5-qtbase-devel
BuildRequires: qt5-qtsvg-devel
BuildRequires: qt5-qt3d-devel
BuildRequires: qt5-qtwebkit-devel
BuildRequires: qt5-qtxmlpatterns-devel
BuildRequires: lpsolve-devel

# We should use clang, but OMEdit doesn't compile with it due to odd default qmake flags
Requires: gcc
Requires: gcc-c++

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
%{summary}

%prep

%setup -q -n openmodelica_%{version}

autoconf
./configure CFLAGS="-Os" CXXFLAGS="-Os" QTDIR=/usr/%{_lib}/qt5/ --with-omniORB --without-cppruntime --without-omc --prefix=/opt/openmodelica-BRANCH --without-omlibrary

%build

make -j8

%install
rm -rf %{buildroot}
make install DESTDIR="%{buildroot}"
ln -s /usr/lib/omlibrary %{buildroot}/opt/openmodelica-BRANCH/lib/

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
/opt/openmodelica-BRANCH/*

%changelog
* DATE  OpenModelica <openmodelica@ida.liu.se> ${version}-1
- First Build
