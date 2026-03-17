#!/bin/bash

SCRIPT_REPO="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT="33a9ede8d9914299d9262539c576a15bd0a19621"

SCRIPT_REPO2="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT2="fe32761e7a8bc79fcf560f356bf3898271bf4d56"
SCRIPT_BRANCH2="sdk/12.0"

SCRIPT_REPO3="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT3="bafcf66bf6f98eb76ed135a75e78913b989cbc89"
SCRIPT_BRANCH3="sdk/12.1"

SCRIPT_REPO4="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT4="f8339c06648fb6642aac1261d76e4158dc0b5401"
SCRIPT_BRANCH4="sdk/12.2"

ffbuild_enabled() {
    [[ $TARGET == winarm64 ]] && return -1
    (( $(ffbuild_ffver) >= 404 )) || return -1
    return 0
}

ffbuild_dockerdl() {
    default_dl ffnvcodec
    echo "git-mini-clone \"$SCRIPT_REPO2\" \"$SCRIPT_COMMIT2\" ffnvcodec2"
    echo "git-mini-clone \"$SCRIPT_REPO3\" \"$SCRIPT_COMMIT3\" ffnvcodec3"
    echo "git-mini-clone \"$SCRIPT_REPO4\" \"$SCRIPT_COMMIT4\" ffnvcodec4"
}

ffbuild_dockerbuild() {
    if (( $FFVER < 700 )); then
        cd ffnvcodec2
    elif (( $FFVER < 701 )); then
        cd ffnvcodec3
    elif (( $FFVER < 800 )); then
        cd ffnvcodec4
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
