#!/bin/bash

SCRIPT_REPO="https://github.com/KhronosGroup/SPIRV-Headers.git"
SCRIPT_COMMIT="869266ad9e6050197d87cf0a22aab59abf7ad008"

ffbuild_enabled() {
    (( $(ffbuild_ffver) > 404 )) || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DSPIRV_HEADERS_ENABLE_TESTS=OFF -DSPIRV_HEADERS_ENABLE_INSTALL=ON ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}
