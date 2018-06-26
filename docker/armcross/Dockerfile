FROM ubuntu:bionic
WORKDIR /workdir
RUN echo "deb [arch=armhf] http://ports.ubuntu.com/ bionic main multiverse universe" >> /etc/apt/sources.list \
 && echo 'APT::Architectures "amd64";' >> /etc/apt/apt.conf.d/50arch \
 && dpkg --add-architecture armhf \
 && cat /etc/apt/sources.list \
 && apt-get update \
 && apt-get -qyy install --no-install-recommends libtinfo5:armhf \
 && apt-get -qyy install --no-install-recommends g++-arm-linux-gnueabihf libboost-filesystem-dev:armhf libboost-system-dev:armhf libreadline-dev:armhf cmake make git \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
