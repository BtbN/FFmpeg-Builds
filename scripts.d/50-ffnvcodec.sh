#!/bin/bash

SCRIPT_REPO="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT="c12df23d145431fb65c2116481aac19340b2cc30"

SCRIPT_REPO2="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT2="b550d4042f1ac0990efa1fa9f0f0c08fb6b24446"
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
