#!/bin/bash

FFNVCODEC_REPO="https://git.videolan.org/git/ffmpeg/nv-codec-headers.git"
FFNVCODEC_COMMIT="c928e22d81869fefb63a86405c0e1cbed8763a9e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /root/ffnvcodec.sh"
    to_df "RUN bash -c 'source /root/ffnvcodec.sh && ffbuild_dockerbuild && rm /root/ffnvcodec.sh'"
}

ffbuild_dockerbuild() {
    git clone "$FFNVCODEC_REPO" ffnvcodec || return -1
    pushd ffnvcodec
    git checkout "$FFNVCODEC_COMMIT" || return -1

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
