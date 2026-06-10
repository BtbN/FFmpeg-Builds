#!/bin/bash

SCRIPT_REPO="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT="1b5a81ada8874efb2af0534ffe74049c557e212d"

SCRIPT_REPO2="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT2="33a9ede8d9914299d9262539c576a15bd0a19621"
SCRIPT_BRANCH2="sdk/13.0"

SCRIPT_REPO3="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT3="afae1834257b919848c5deb21a17c7355616b1ee"
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
