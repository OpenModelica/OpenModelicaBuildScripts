FROM docker.openmodelica.org/build-deps

VOLUME /workdir
WORKDIR /workdir

COPY MacOSX10.11.sdk.tar.xz /workdir/MacOSX10.11.sdk.tar.xz

ENV MACOSX_DEPLOYMENT_TARGET=10.9 PATH="/opt/osxcross/bin:${PATH}"

RUN export PATH=$PATH:/workdir/osxcross/target/bin HOME=/workdir \
  && git clone --depth=1 https://github.com/tpoechtrager/osxcross \
  && cp MacOSX10.11.sdk.tar.xz osxcross/tarballs \
  && cd osxcross \
  && UNATTENDED=1 OSX_VERSION_MIN=10.9 ./build.sh \
  && ./target/bin/osxcross-macports clear-cache || true \
  && echo http://nue.de.packages.macports.org/macports/packages > target/macports/MIRROR \
  && ./target/bin/osxcross-macports clear-cache \
  && mv target /opt/osxcross \
  && cd .. \
  && rm -rf /var/lib/apt/lists/* \
  && rm -f /workdir/MacOSX10.11.sdk.tar.xz \
  && rm -rf /workdir/osxcross \
  && ln -s /opt/osxcross/bin/x86_64-apple-darwin15-libtool /usr/bin/libtool
