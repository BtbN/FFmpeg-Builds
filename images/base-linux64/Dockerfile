ARG GH_REPO=ghcr.io/btbn/ffmpeg-builds
FROM $GH_REPO/base:latest

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
    find /opt/ct-ng -type l \
        -and -name '*.so' \
        -and -not -ipath '*plugin*' \
        -and -not -name 'libdl.*' \
        -and -not -name 'libc.*' \
        -and -not -name 'libm.*' \
        -and -not -name 'libmvec.*' \
        -and -not -name 'librt.*' \
        -and -not -name 'libpthread.*' \
        -delete && \
    find /opt/ct-ng \
        -name 'libdl.a' \
        -or -name 'libc.a' \
        -or -name 'libm.a' \
        -or -name 'libmvec.a' \
        -or -name 'librt.a' \
        -or -name 'libpthread.a' \
        -delete && \
    mkdir /opt/ffbuild

ENV FFBUILD_TOOLCHAIN=x86_64-ffbuild-linux-gnu \
    FFBUILD_RUST_TARGET="x86_64-unknown-linux-gnu"

RUN \
    rustup default nightly && \
    echo "[unstable]\ntarget-applies-to-host = true\nhost-config = true\n" > "$CARGO_HOME"/config.toml && \
    echo "[target.$FFBUILD_RUST_TARGET]\nlinker = \"${FFBUILD_TOOLCHAIN}-gcc\"\nar = \"${FFBUILD_TOOLCHAIN}-gcc-ar\"\n" >> "$CARGO_HOME"/config.toml && \
    echo "[target.host]\nlinker = \"gcc\"\nar = \"ar\"\n" >> "$CARGO_HOME"/config.toml

ADD toolchain.cmake /toolchain.cmake
ADD cross.meson /cross.meson

ADD gen-implib.sh /usr/bin/gen-implib
RUN git clone --filter=blob:none --depth=1 https://github.com/yugr/Implib.so /opt/implib

ENV PATH="/opt/ct-ng/bin:${PATH}" \
    FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=${FFBUILD_TOOLCHAIN}- --arch=x86_64 --target-os=linux" \
    FFBUILD_CROSS_PREFIX="${FFBUILD_TOOLCHAIN}-" \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG=pkg-config \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig \
    CC="${FFBUILD_TOOLCHAIN}-gcc" \
    CXX="${FFBUILD_TOOLCHAIN}-g++" \
    LD="${FFBUILD_TOOLCHAIN}-ld" \
    AR="${FFBUILD_TOOLCHAIN}-gcc-ar" \
    RANLIB="${FFBUILD_TOOLCHAIN}-gcc-ranlib" \
    NM="${FFBUILD_TOOLCHAIN}-gcc-nm" \
    CFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -fPIC -DPIC -D_FORTIFY_SOURCE=2 -fstack-protector-strong -fstack-clash-protection -pthread" \
    CXXFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -fPIC -DPIC -D_FORTIFY_SOURCE=2 -fstack-protector-strong -fstack-clash-protection -pthread" \
    LDFLAGS="-static-libgcc -static-libstdc++ -L/opt/ffbuild/lib -O2 -pipe -fstack-protector-strong -fstack-clash-protection -Wl,-z,relro,-z,now -pthread -lm" \
    STAGE_CFLAGS="-fvisibility=hidden -fno-semantic-interposition" \
    STAGE_CXXFLAGS="-fvisibility=hidden -fno-semantic-interposition"
