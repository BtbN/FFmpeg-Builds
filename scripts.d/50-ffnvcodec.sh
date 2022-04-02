#!/bin/bash

FFNVCODEC_REPO="https://github.com/FFmpeg/nv-codec-headers.git"
FFNVCODEC_COMMIT="84483da70d903239d4536763fde8c7e6c4e80784"

ffbuild_enabled() {
    return -1
}

ffbuild_dockerbuild() {
    git-mini-clone "$FFNVCODEC_REPO" "$FFNVCODEC_COMMIT" ffnvcodec
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
