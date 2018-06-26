FROM ubuntu:bionic
WORKDIR /workdir
RUN echo "deb [arch=armhf] http://ports.ubuntu.com/ bionic main multiverse universe" >> /etc/apt/sources.list \
 && echo 'APT::Architectures "amd64";' >> /etc/apt/apt.conf.d/50arch \
 && dpkg --add-architecture armhf \
 && cat /etc/apt/sources.list \
 && apt-get update \
 && apt-get -qyy install libtinfo5:armhf \
 && apt-get -qyy install g++-arm-linux-gnueabihf libboost-filesystem-dev:armhf libboost-system-dev:armhf libreadline-dev:armhf cmake make \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
