ARG DIST=ubuntu:bionic
FROM ${DIST}
WORKDIR /workdir
RUN (grep arch=armhf /etc/apt/sources.list || echo "deb [arch=armhf] http://ports.ubuntu.com/ bionic main multiverse universe" >> /etc/apt/sources.list) \
 && echo 'APT::Architectures "amd64";' >> /etc/apt/apt.conf.d/50arch \
 && dpkg --add-architecture armhf \
 && cat /etc/apt/sources.list \
 && apt-get update \
 && apt-get -qyy install --no-install-recommends libtinfo5:armhf \
 && apt-get -qyy install g++-arm-linux-gnueabihf libboost-filesystem-dev:armhf libboost-system-dev:armhf libreadline-dev:armhf cmake make git ca-certificates autoconf automake \
 && ln -sf /usr/bin/arm-linux-gnueabihf-ranlib /usr/bin/ranlib \
 && ln -sf /usr/bin/arm-linux-gnueabihf-ar /usr/bin/ar \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
