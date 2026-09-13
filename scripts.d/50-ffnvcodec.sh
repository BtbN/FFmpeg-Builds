#!/bin/bash

SCRIPT_REPO="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT="eddcea9e27f6b772057c9b3f87de2cc1737faffc"

SCRIPT_REPO2="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT2="ced4f8eba3ba5dd431932cba17928f0dffdaeb2b"
SCRIPT_BRANCH2="sdk/13.0"

SCRIPT_REPO3="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT3="833faee5f7b8d3f56444347c587f4aed11ee213f"
SCRIPT_BRANCH3="sdk/11.1"

ffbuild_enabled() {
    [[ $TARGET == winarm64 ]] && (( $(ffbuild_ffver) <= 801 )) && return -1
    (( $(ffbuild_ffver) >= 404 )) || return -1
    return 0
}

ffbuild_dockerdl() {
    default_dl ffnvcodec
    echo "git-mini-clone \"$SCRIPT_REPO2\" \"$SCRIPT_COMMIT2\" ffnvcodec2"
    echo "git-mini-clone \"$SCRIPT_REPO3\" \"$SCRIPT_COMMIT3\" ffnvcodec3"
}

ffbuild_dockerbuild() {
    if (( $FFVER < 800 )); then
        cd ffnvcodec3
    elif (( $FFVER <= 801 )); then
        cd ffnvcodec2
    else
        cd ffnvcodec
    fi

    make PREFIX="$FFBUILD_PREFIX" DESTDIR="$FFBUILD_DESTDIR" install
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
