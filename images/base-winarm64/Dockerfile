ARG GH_REPO=ghcr.io/btbn/ffmpeg-builds
FROM $GH_REPO/base:latest

RUN \
    git clone --filter=blob:none https://github.com/mstorsjo/llvm-mingw /llvm-mingw && cd /llvm-mingw && \
    ./build-all.sh --disable-lldb --disable-lldb-mi /opt/llvm-mingw && \
    cd / && \
    rm -rf llvm-mingw

# LLVM/Clang workarounds
RUN \
    ln -s windows.h /opt/llvm-mingw/generic-w64-mingw32/include/Windows.h

# Prepare "cross" environment to heavily favour static builds
RUN \
    find /opt/llvm-mingw \
        -name "*.dll" \
        -or -name "*.dll.a" \
        -delete && \
    mkdir /opt/ffbuild

ENV FFBUILD_TOOLCHAIN=aarch64-w64-mingw32 \
    FFBUILD_RUST_TARGET=aarch64-pc-windows-gnullvm

RUN \
    rustup target add "$FFBUILD_RUST_TARGET" && \
    echo "[target.$FFBUILD_RUST_TARGET]\nlinker = \"${FFBUILD_TOOLCHAIN}-clang\"\nar = \"${FFBUILD_TOOLCHAIN}-llvm-ar\"\n" >> "$CARGO_HOME"/config.toml

ADD toolchain.cmake /toolchain.cmake
ADD cross.meson /cross.meson

ENV PATH="/opt/llvm-mingw/bin:${PATH}" \
    FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=${FFBUILD_TOOLCHAIN}- --arch=aarch64 --target-os=mingw32" \
    FFBUILD_CROSS_PREFIX=${FFBUILD_TOOLCHAIN}- \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG=pkg-config \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig \
    COMPILER_SYSROOT=/opt/llvm-mingw/aarch64-w64-mingw32 \
    CC="${FFBUILD_TOOLCHAIN}-clang" \
    CXX="${FFBUILD_TOOLCHAIN}-clang++" \
    LD="${FFBUILD_TOOLCHAIN}-ld" \
    AR="${FFBUILD_TOOLCHAIN}-llvm-ar" \
    RANLIB="${FFBUILD_TOOLCHAIN}-llvm-ranlib" \
    NM="${FFBUILD_TOOLCHAIN}-nm" \
    DLLTOOL="${FFBUILD_TOOLCHAIN}-dlltool" \
    CFLAGS="-I/opt/ffbuild/include -O2 -pipe -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    CXXFLAGS="-I/opt/ffbuild/include -O2 -pipe -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    LDFLAGS="-L/opt/ffbuild/lib -O2 -pipe -fstack-protector-strong" \
    STAGE_CFLAGS="" \
    STAGE_CXXFLAGS=""
