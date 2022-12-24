#!/bin/bash

SCRIPT_REPO="https://github.com/libsndfile/libsamplerate.git"
SCRIPT_COMMIT="a9945ab36e827260cacf7b3e4f6e783b460e21ee"

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
