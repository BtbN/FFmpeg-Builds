#!/bin/bash

SCRIPT_REPO="https://github.com/mpeg5/xeve.git"
SCRIPT_COMMIT="429c18a7736ffc010e1c550e8015ff18a242d06c"

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

    mv "$FFBUILD_DESTPREFIX"/lib/{xeve/libxeve.a,}
    rm -rf "$FFBUILD_DESTPREFIX"/lib/{libxeve.dll*,xeve,xeve_base}

    echo "Cflags.private: -DXEVE_STATIC_DEFINE" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/xeve.pc
}

ffbuild_configure() {
    (( $(ffbuild_ffver) >= 700 )) || return 0
    echo --enable-libxeve
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) >= 700 )) || return 0
    echo --disable-libxeve
}
