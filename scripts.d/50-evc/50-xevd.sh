#!/bin/bash

SCRIPT_REPO="https://github.com/mpeg5/xevd.git"
SCRIPT_COMMIT="4087f635624cf4ee6ebe3f9ea165ff939b32117f"

ffbuild_enabled() {
    (( $(ffbuild_ffver) >= 700 )) || return -1
    [[ $TARGET == *32 ]] && return -1
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo "git fetch --unshallow"
}

ffbuild_dockerbuild() {
    mkdir ffbuild && cd ffbuild

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        ..
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"

    mv "$FFBUILD_DESTPREFIX"/lib/{xevd/libxevd.a,}
    rm -rf "$FFBUILD_DESTPREFIX"/lib/{libxevd.dll*,xevd,xevd_base}

    echo "Cflags.private: -DXEVD_STATIC_DEFINE" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/xevd.pc
}

ffbuild_configure() {
    (( $(ffbuild_ffver) >= 700 )) || return 0
    echo --enable-libxevd
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) >= 700 )) || return 0
    echo --disable-libxevd
}
