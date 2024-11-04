#!/bin/bash

SCRIPT_REPO="https://github.com/ARMmbed/mbedtls.git"
SCRIPT_COMMIT="v3.6.2"
SCRIPT_TAGFILTER="v3.*"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo "git submodule update --init --recursive --depth=1"
}

ffbuild_dockerbuild() {
    if [[ $TARGET == win32 ]]; then
        python3 scripts/config.py unset MBEDTLS_AESNI_C
    fi

    mkdir build && cd build

    # Let's hope this is just a false-positive
    export CFLAGS="$CFLAGS -Wno-error=array-bounds"

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DENABLE_PROGRAMS=OFF -DENABLE_TESTING=OFF -DGEN_FILES=ON \
        -DUSE_STATIC_MBEDTLS_LIBRARY=ON -DUSE_SHARED_MBEDTLS_LIBRARY=OFF -DINSTALL_MBEDTLS_HEADERS=ON \
        ..
    make -j$(nproc)
    make install

    if [[ $TARGET == win* ]]; then
        echo "Libs.private: -lws2_32 -lbcrypt -lwinmm -lgdi32" >> "$FFBUILD_PREFIX"/lib/pkgconfig/mbedcrypto.pc
    fi
}
