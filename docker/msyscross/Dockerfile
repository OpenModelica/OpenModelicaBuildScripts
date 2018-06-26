ARG DIST=ubuntu:bionic
FROM ${DIST}
WORKDIR /workdir
COPY pacman.conf /workdir/pacman.conf
RUN apt-get update \
 && apt-get -qyy install mingw-w64 cmake make git ca-certificates autoconf automake autopoint wget pkg-config libarchive-dev \
 && wget https://git.archlinux.org/pacman.git/snapshot/pacman-5.1.0.tar.xz -O- | tar xJ \
 && cd pacman-5.1.0 && ./autogen.sh && ./configure --prefix=/opt/pacman --disable-doc && make -j4 && make -j4 install \
 && cp /workdir/pacman.conf /opt/pacman/etc/pacman.conf \
 && /opt/pacman/bin/pacman -Sy mingw-w64-i686-readline mingw-w64-i686-readline mingw-w64-x86_64-readline \
 && cd /workdir \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /opt/pacman/var/cache/pacman/pkg/* /opt/pacman/var/lib/pacman/sync/* /workdir/*
