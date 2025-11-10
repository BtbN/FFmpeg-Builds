#!/bin/bash

SCRIPT_REPO="https://github.com/ARMmbed/mbedtls.git"
SCRIPT_COMMIT="v3.6.5"
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

    # Let's hope this is just a false-positive
    export CFLAGS="$CFLAGS -Wno-error=array-bounds"
    if [[ $CC != *clang* ]]; then
        export CFLAGS="$CFLAGS -Wno-error=unterminated-string-initialization"
    fi

    build_cmake \
        -DENABLE_PROGRAMS=OFF \
        -DENABLE_TESTING=OFF \
        -DGEN_FILES=ON \
        -DUSE_STATIC_MBEDTLS_LIBRARY=ON \
        -DUSE_SHARED_MBEDTLS_LIBRARY=OFF \
        -DINSTALL_MBEDTLS_HEADERS=ON

    if [[ $TARGET == win* ]]; then
        add_pkgconfig_libs_private mbedcrypto ws2_32 bcrypt winmm gdi32
    fi
}
