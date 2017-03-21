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
SOURCE0 : https://build.openmodelica.org/apt/pool/contrib/openmodelica_%{version}.orig.tar.xz
URL: https://openmodelica.org/

BuildRequires: automake
BuildRequires: omniORB
BuildRequires: gcc
BuildRequires: gcc-gfortran
BuildRequires: gcc-c++
BuildRequires: qt5-qtbase-devel
BuildRequires: qt5-qtsvg-devel
BuildRequires: qt5-qt3d-devel
BuildRequires: qt5-qtwebkit-devel
BuildRequires: lpsolve-devel

Requires: clang
Requires: gcc-c++

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
%{summary}

%prep

%setup -q -n openmodelica_%{version}

autoconf
./configure CC=clang CXX=g++ CFLAGS="-Os" CXXFLAGS="-Os" --with-omniORB --without-cppruntime --without-omc --prefix=/opt/openmodelica-BRANCH --without-omlibrary

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
