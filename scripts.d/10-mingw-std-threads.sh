#!/bin/bash

MINGW_STD_THREADS_REPO="https://github.com/meganz/mingw-std-threads.git"
MINGW_STD_THREADS_COMMIT="7e2507915900f5589febf0d8972cd5c9c03191f2"

ffbuild_enabled() {
    [[ $TARGET == win* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$MINGW_STD_THREADS_REPO" "$MINGW_STD_THREADS_COMMIT" mingw-std-threads
    cd mingw-std-threads

    mkdir -p "$FFBUILD_PREFIX"/include
    cp *.h "$FFBUILD_PREFIX"/include
}
