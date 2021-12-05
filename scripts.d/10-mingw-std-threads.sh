#!/bin/bash

MINGW_STD_THREADS_REPO="https://github.com/meganz/mingw-std-threads.git"
MINGW_STD_THREADS_COMMIT="f73afbe664bf3beb93a01274246de80d543adf6e"

ffbuild_enabled() {
    [[ $TARGET == win* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$MINGW_STD_THREADS_REPO" "$MINGW_STD_THREADS_COMMIT" mingw-std-threads
    cd mingw-std-threads

    mkdir -p "$FFBUILD_PREFIX"/include
    cp *.h "$FFBUILD_PREFIX"/include

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DMINGW_STDTHREADS_DIR="$FFBUILD_PREFIX"/include -DMINGW_STDTHREADS_BUILD_TEST=0 -DMINGW_STDTHREADS_GENERATE_STDHEADERS=1 .
    cp cmake_stdheaders_generator/cmake_stdheaders_generator/* "$FFBUILD_PREFIX"/include
}
