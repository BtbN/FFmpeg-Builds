ARG GH_REPO=btbn/ffmpeg-builds
FROM ghcr.io/$GH_REPO/base:latest

ENV PATH="/opt/ct-ng/bin:${PATH}"
RUN --mount=src=ct-ng-config,dst=/.config \
    git clone https://github.com/crosstool-ng/crosstool-ng.git /ct-ng && cd /ct-ng && \
    ./bootstrap && \
    ./configure --enable-local && \
    make -j$(nproc) && \
    cp /.config .config && \
    ./ct-ng build && \
    cd / && \
    rm -rf ct-ng

# Prepare "cross" environment to heavily favour static builds
RUN \
    find /opt/ct-ng -type l \
        -and -name '*.so' \
        -and -not -ipath '*plugin*' \
        -and -not -name 'libdl.*' \
        -and -not -name 'libc.*' \
        -and -not -name 'libm.*' \
        -delete && \
    find /opt/ct-ng \
        -name 'libdl.a' \
        -or -name 'libc.a' \
        -or -name 'libm.a' \
        -delete

ADD toolchain.cmake /toolchain.cmake
ADD cross.meson /cross.meson

ENV FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=x86_64-ffbuild-linux-gnu- --arch=x86_64 --target-os=linux" \
    FFBUILD_TOOLCHAIN=x86_64-ffbuild-linux-gnu \
    FFBUILD_CROSS_PREFIX="x86_64-ffbuild-linux-gnu-" \
    FFBUILD_RUST_TARGET="x86_64-unknown-linux-gnu" \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig \
    CFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -fPIC -DPIC -D_FORTIFY_SOURCE=2 -fstack-protector-strong -pthread" \
    CXXFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -fPIC -DPIC -D_FORTIFY_SOURCE=2 -fstack-protector-strong -pthread" \
    LDFLAGS="-static-libgcc -static-libstdc++ -L/opt/ffbuild/lib -O2 -pipe -fstack-protector-strong -Wl,-z,relro,-z,now -pthread -lm" \
    STAGE_CFLAGS="-fvisibility=hidden" \
    STAGE_CXXFLAGS="-fvisibility=hidden"
