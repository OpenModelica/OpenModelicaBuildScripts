ARG DIST=ubuntu:bionic
FROM ${DIST}
WORKDIR /workdir
COPY pacman.conf /workdir/pacman.conf
RUN apt-get update \
 && apt-get -qyy --no-install-recommends install g++ make ca-certificates autoconf automake autopoint curl libcurl4-gnutls-dev pkg-config libarchive-dev libssl-dev libtool gettext \
 && curl -s https://git.archlinux.org/pacman.git/snapshot/pacman-5.1.0.tar.xz | tar xJ \
 && cd pacman-5.1.0 && ./autogen.sh && ./configure --prefix=/opt/pacman --disable-doc && make -j4 && make -j4 install \
 && cp /workdir/pacman.conf /opt/pacman/etc/pacman.conf \
 && /opt/pacman/bin/pacman -Sy --noconfirm mingw-w64-i686-readline mingw-w64-i686-readline mingw-w64-x86_64-readline mingw-w64-i686-boost mingw-w64-x86_64-boost \
 && apt-get -qyy install mingw-w64 cmake git \
 && cd /workdir \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /opt/pacman/var/cache/pacman/pkg/* /opt/pacman/var/lib/pacman/sync/* /workdir/*
