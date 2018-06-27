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
  && wget -q https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz \
  && tar xzf boost_1_67_0.tar.gz \
  && cd boost_1_67_0 \
  && ./bootstrap.sh \
  && echo "using gcc : darwin : x86_64-apple-darwin15-c++ ;" > $HOME/user-config.jam \
  && ./b2 --prefix=/opt/osxcross/macports/pkgs/opt/local/ -d0 --with-filesystem --with-system --no-tests toolset=gcc-darwin link=static cxxflags="-std=c++11 -stdlib=libc++" install \
  && find /opt/osxcross/macports/pkgs/opt/local/ -name "*.a" -exec x86_64-apple-darwin15-ranlib {} ";" \
  && rm -rf /var/lib/apt/lists/* \
  && rm -f /workdir/MacOSX10.11.sdk.tar.xz \
  && rm -rf /workdir/osxcross \
  && ln -s /opt/osxcross/bin/x86_64-apple-darwin15-libtool /usr/bin/libtool
