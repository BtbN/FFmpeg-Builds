#!/bin/bash

FFNVCODEC_REPO="https://git.videolan.org/git/ffmpeg/nv-codec-headers.git"
FFNVCODEC_COMMIT="c928e22d81869fefb63a86405c0e1cbed8763a9e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$FFNVCODEC_REPO" "$FFNVCODEC_COMMIT" ffnvcodec
    pushd ffnvcodec

    make PREFIX="$FFBUILD_PREFIX" install || return -1

    popd
    rm -rf ffnvcodec
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
