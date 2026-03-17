#!/bin/bash

SCRIPT_REPO="https://github.com/google/brotli.git"
SCRIPT_COMMIT="408457d9c5d2ae8a0b3a4889298bf0bab16089b1"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_SHARED_LIBS=OFF ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}
