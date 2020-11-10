#!/bin/bash

FFNVCODEC_REPO="https://github.com/FFmpeg/nv-codec-headers.git"
FFNVCODEC_COMMIT="f85a70af7100a4a302a1562abdb96d8e8db87ff4"

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
