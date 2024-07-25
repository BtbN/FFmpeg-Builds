#!/bin/bash

SCRIPT_REPO="https://github.com/fraunhoferhhi/vvenc.git"

ffbuild_enabled() {
    [[ $ADDINS_STR == *4.4* ]] && return -1
    [[ $ADDINS_STR == *5.0* ]] && return -1
    [[ $ADDINS_STR == *5.1* ]] && return -1
    [[ $ADDINS_STR == *6.0* ]] && return -1
    [[ $ADDINS_STR == *6.1* ]] && return -1
    [[ $ADDINS_STR == *7.0* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local fixarm64=""
    if [[ $TARGET == *arm64 ]]; then
        fixarm64 = "-DVVENC_ENABLE_X86_SIMD=OFF -DVVENC_ENABLE_ARM_SIMD=OFF"
    fi

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" $fixarm64 ..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    [[ $ADDINS_STR == *4.4* ]] && return 0
    [[ $ADDINS_STR == *5.0* ]] && return 0
    [[ $ADDINS_STR == *5.1* ]] && return 0
    [[ $ADDINS_STR == *6.0* ]] && return 0
    [[ $ADDINS_STR == *6.1* ]] && return 0
    [[ $ADDINS_STR == *7.0* ]] && return 0
    echo --enable-libvvenc
}

ffbuild_unconfigure() {
    [[ $ADDINS_STR == *4.4* ]] && return 0
    [[ $ADDINS_STR == *5.0* ]] && return 0
    [[ $ADDINS_STR == *5.1* ]] && return 0
    [[ $ADDINS_STR == *6.0* ]] && return 0
    [[ $ADDINS_STR == *6.1* ]] && return 0
    [[ $ADDINS_STR == *7.0* ]] && return 0
    echo --disable-libvvenc
}