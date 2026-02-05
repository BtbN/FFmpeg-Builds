#!/bin/bash

SCRIPT_REPO="https://github.com/hoene/libmysofa.git"
SCRIPT_COMMIT="3f4cb663f171ecb5c6fc3262fb6156efb3f1ddd2"

ffbuild_depends() {
    echo base
    echo zlib
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir ffbuild && cd ffbuild

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_TESTS=OFF \
        ..
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"

    echo "Libs.private: -lz" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/libmysofa.pc
}

ffbuild_configure() {
    echo --enable-libmysofa
}

ffbuild_unconfigure() {
    echo --disable-libmysofa
}
