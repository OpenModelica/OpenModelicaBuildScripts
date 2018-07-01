FROM ubuntu:bionic

ARG VERSION=2.0.4

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get upgrade -qy && apt-get dist-upgrade -qy \
 && apt-get install -qy wget ca-certificates unzip subversion cmake g++ \
 && wget https://svn.fmi-standard.org/fmi/branches/public/Test_FMUs/Compliance-Checker/FMUChecker-${VERSION}-src.zip \
 && unzip FMUChecker-${VERSION}-src.zip \
 && mkdir -p FMUChecker-${VERSION}/build \
 && (cd FMUChecker-${VERSION}/build && cmake .. -DFMUCHK_FMI_PLATFORM=arm-linux-gnueabihf && make -j3) \
 && cp FMUChecker-${VERSION}/build/fmuCheck.arm-linux-gnueabihf /usr/local/bin \
 && apt-get autoremove -qy wget ca-certificates subversion cmake g++ \
 && fmuCheck.arm-linux-gnueabihf -v \
 && rm -rf *.zip /var/lib/apt/lists/* FMUChecker-${VERSION}
