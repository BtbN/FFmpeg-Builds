#!/bin/bash

SCRIPT_REPO="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT="4fd7be29a431441ca31b8db0155875ae2ff4ed47"

SCRIPT_REPO2="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT2="2cd175b30366b6e295991ee0540e3e875cce6f2e"
SCRIPT_BRANCH2="sdk/11.1"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    default_dl ffnvcodec
    to_df "RUN git-mini-clone \"$SCRIPT_REPO2\" \"$SCRIPT_COMMIT2\" ffnvcodec2"
}

ffbuild_dockerbuild() {
    if [[ $ADDINS_STR == *4.4* || $ADDINS_STR == *5.0* || $ADDINS_STR == *5.1* ]]; then
        cd "$FFBUILD_DLDIR"/ffnvcodec2
    else
        cd "$FFBUILD_DLDIR"/ffnvcodec
    fi

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
