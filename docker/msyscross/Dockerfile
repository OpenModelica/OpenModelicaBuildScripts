ARG DIST=ubuntu:disco

FROM ${DIST}

ARG ARCH=x86_64
ARG LINKCPPFS=true

WORKDIR /workdir
COPY pacman.conf /workdir/pacman.conf
# We use Ubuntu Disco since the MinGW version matches gcc in the MSYS2 repo
RUN sed -i s,http://archive.ubuntu.com/ubuntu/,mirror://mirrors.ubuntu.com/mirrors.txt, /etc/apt/sources.list \
 && dpkg --add-architecture i386 && apt-get update \
 && apt-get -qyy --no-install-recommends install g++ make ca-certificates autoconf automake autopoint curl libcurl4-gnutls-dev pkg-config libarchive-dev libssl-dev libtool gettext zip \
 && curl -s https://git.archlinux.org/pacman.git/snapshot/pacman-5.1.0.tar.xz | tar xJ \
 && cd pacman-5.1.0 && ./autogen.sh && ./configure --prefix=/opt/pacman --disable-doc && make -j4 && make -j4 install \
 && cp /workdir/pacman.conf /opt/pacman/etc/pacman.conf \
 && /opt/pacman/bin/pacman -Sy --noconfirm mingw-w64-$ARCH-readline mingw-w64-$ARCH-boost mingw-w64-$ARCH-python3 mingw-w64-$ARCH-libiconv mingw-w64-$ARCH-libxml2 mingw-w64-$ARCH-gcc \
 && apt-get -qyy install mingw-w64 cmake git software-properties-common unzip wine64 wine32 wine-stable perl libmldbm-perl flex gcc \
 && if $LINKCPPFS; then ln -s /opt/pacman/mingw64/lib/gcc/$ARCH-w64-mingw32/*/libstdc++fs.a /usr/lib/gcc/$ARCH-w64-mingw32/*-posix; fi  \
 && cd /workdir \
 && find /opt/pacman /usr -name "*.dll.a" -exec rm {} ";" \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /opt/pacman/var/cache/pacman/pkg/* /opt/pacman/var/lib/pacman/sync/* /workdir/*
