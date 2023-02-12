#!/bin/bash

SCRIPT_REPO="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT="c5e4af74850a616c42d39ed45b9b8568b71bf8bf"

SCRIPT_REPO2="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT2="2055784e5d5bfb3df78d4d3645f345f19062dce2"
SCRIPT_BRANCH2="sdk/11.1"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    if [[ $ADDINS_STR == *4.4* || $ADDINS_STR == *5.0* || $ADDINS_STR == *5.1* ]]; then
        SCRIPT_COMMIT="$SCRIPT_COMMIT2"
    fi

    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" ffnvcodec
    cd ffnvcodec

    make PREFIX="$FFBUILD_PREFIX" install
}

ffbuild_configure() {
    echo --enable-ffnvcodec --enable-cuda-llvm
}

ffbuild_unconfigure() {
    echo --disable-ffnvcodec --disable-cuda-llvm
}

ffbuild_cflags() {
    return 0
}

ffbuild_ldflags() {
    return 0
}
