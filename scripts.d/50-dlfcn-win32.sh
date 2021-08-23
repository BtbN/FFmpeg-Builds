#!/bin/bash

DLFCN_WIN32_REPO="https://github.com/dlfcn-win32/dlfcn-win32.git"
DLFCN_WIN32_COMMIT="010969070719fe14435f4b146ecef5e65df0098f"

ffbuild_enabled() {
    [[ $TARGET != win* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$DLFCN_WIN32_REPO" "$DLFCN_WIN32_COMMIT" dlfcn-win32
    cd dlfcn-win32

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTS=OFF ..
    make -j$(nproc)
    make install
}
