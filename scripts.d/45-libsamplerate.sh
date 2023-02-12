#!/bin/bash

SCRIPT_REPO="https://github.com/libsndfile/libsamplerate.git"
SCRIPT_COMMIT="c01e2405612ad3561bf93e8e6dddb9ba0dffe4d9"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" libsr
    cd libsr

    mkdir build
    cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=NO -DBUILD_TESTING=NO -DLIBSAMPLERATE_EXAMPLES=OFF -DLIBSAMPLERATE_INSTALL=YES ..
    make -j$(nproc)
    make install
}
