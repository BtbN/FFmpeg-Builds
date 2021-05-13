FROM alpine:edge

ENV CARGO_HOME="/opt/cargo" PATH="/opt/cargo/bin:${PATH}"
RUN \
    apk add --no-cache \
        yasm nasm diffutils xxd pkgconf git ca-certificates curl wget unzip subversion autoconf automake libtool perl make cmake clang texinfo gperf gettext gettext-dev gettext-static itstool ragel musl-dev openssl-dev zlib-dev bzip2-static gtk-doc gobject-introspection gawk meson samurai p7zip python3 \
        binutils gcc g++ gfortran \
        rust cargo && \
    ln -s python3 /usr/bin/python && \
    cargo install cargo-c && rm -rf "${CARGO_HOME}"/{registry,git} && \
    git config --global user.email "builder@localhost" && \
    git config --global user.name "Builder" && \
    mkdir /opt/ffbuild

ADD run_stage.sh /usr/bin/run_stage
ADD git-mini-clone.sh /usr/bin/git-mini-clone
ADD check-wget.sh /usr/bin/check-wget

ADD toolchain.cmake /toolchain.cmake
ADD cross.meson /cross.meson

ENV FFBUILD_TARGET_FLAGS="" \
    FFBUILD_TOOLCHAIN=x86_64-alpine-linux-musl \
    FFBUILD_CROSS_PREFIX="" \
    FFBUILD_RUST_TARGET="" \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig \
    CFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    CXXFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    LDFLAGS="-static-libgcc -static-libstdc++ -L/opt/ffbuild/lib -O2 -pipe -fstack-protector-strong"
