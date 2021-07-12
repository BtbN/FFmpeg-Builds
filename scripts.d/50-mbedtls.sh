#!/bin/bash

MBEDTLS_REPO="https://github.com/ARMmbed/mbedtls.git"
# HEAD of development_2.x
MBEDTLS_COMMIT="8de3633c658dbbdfe70b6f13149e975c2c6bf88f"

ffbuild_enabled() {
    [[ $TARGET == win* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$MBEDTLS_REPO" "$MBEDTLS_COMMIT" mbedtls
    cd mbedtls

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DENABLE_PROGRAMS=OFF -DENABLE_TESTING=OFF \
        -DUSE_STATIC_MBEDTLS_LIBRARY=ON -DUSE_SHARED_MBEDTLS_LIBRARY=OFF -DINSTALL_MBEDTLS_HEADERS=ON \
        ..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-mbedtls
}
