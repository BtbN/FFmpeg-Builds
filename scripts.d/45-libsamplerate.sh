#!/bin/bash

SCRIPT_REPO="https://github.com/libsndfile/libsamplerate.git"
SCRIPT_COMMIT="0844c208f683527c08ea8a80acc13b398aa9c8bf"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir build
    cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=NO -DBUILD_TESTING=NO -DLIBSAMPLERATE_EXAMPLES=OFF -DLIBSAMPLERATE_INSTALL=YES ..
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}
