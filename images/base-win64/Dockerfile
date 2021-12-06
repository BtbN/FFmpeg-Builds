ARG GH_REPO=btbn/ffmpeg-builds
FROM ghcr.io/$GH_REPO/base:latest

RUN --mount=src=ct-ng-config,dst=/.config \
    git clone --filter=blob:none https://github.com/crosstool-ng/crosstool-ng.git /ct-ng && cd /ct-ng && \
    ./bootstrap && \
    ./configure --enable-local && \
    make -j$(nproc) && \
    cp /.config .config && \
    ./ct-ng build && \
    cd / && \
    rm -rf ct-ng

# Prepare "cross" environment to heavily favour static builds
RUN \
    find /opt/ct-ng \
        -name "*.dll" \
        -or -name "*.dll.a" \
        -delete && \
    mkdir /opt/ffbuild

RUN rustup target add x86_64-pc-windows-gnu

ADD toolchain.cmake /toolchain.cmake
ADD cross.meson /cross.meson

ENV PATH="/opt/ct-ng/bin:${PATH}" \
    FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=x86_64-w64-mingw32- --arch=x86_64 --target-os=mingw32" \
    FFBUILD_TOOLCHAIN=x86_64-w64-mingw32 \
    FFBUILD_CROSS_PREFIX=x86_64-w64-mingw32- \
    FFBUILD_RUST_TARGET=x86_64-pc-windows-gnu \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG=pkg-config \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig \
    CFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    CXXFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    LDFLAGS="-static-libgcc -static-libstdc++ -L/opt/ffbuild/lib -O2 -pipe -fstack-protector-strong" \
    DLLTOOL="x86_64-w64-mingw32-dlltool" \
    STAGE_CFLAGS="-fno-semantic-interposition" \
    STAGE_CXXFLAGS="-fno-semantic-interposition"
