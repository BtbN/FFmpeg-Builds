#!/bin/bash

SCRIPT_REPO="https://github.com/ngtcp2/nghttp3.git"
SCRIPT_COMMIT="2304973e5a0c8b1fa4bb380b47945a000357f87f"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo "git submodule update --init --recursive --depth=1 lib/sfparse"
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DENABLE_SHARED_LIB=OFF -DENABLE_STATIC_LIB=ON -DENABLE_LIB_ONLY=ON -DBUILD_TESTING=OFF ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    echo "Cflags.private: -DNGHTTP3_STATICLIB" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/libnghttp3.pc
}
