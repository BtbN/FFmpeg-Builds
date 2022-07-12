#!/bin/bash

SCRIPT_REPO="https://github.com/ARMmbed/mbedtls.git"
SCRIPT_COMMIT="v3.2.1"
SCRIPT_TAGFILTER="v3.*"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" mbedtls
    cd mbedtls

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DENABLE_PROGRAMS=OFF -DENABLE_TESTING=OFF -DGEN_FILES=ON \
        -DUSE_STATIC_MBEDTLS_LIBRARY=ON -DUSE_SHARED_MBEDTLS_LIBRARY=OFF -DINSTALL_MBEDTLS_HEADERS=ON \
        ..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    [[ $TARGET == win* ]] && return -1
    echo --enable-mbedtls
}
