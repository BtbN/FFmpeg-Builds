#!/bin/bash

GME_REPO="https://bitbucket.org/mpyne/game-music-emu.git"
GME_COMMIT="d39b0bce47f66074c6aa85202b8cb4642fa77b78"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone "$GME_REPO" gme
    cd gme
    git checkout "$GME_COMMIT"

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=OFF -DENABLE_UBSAN=OFF ..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libgme
}

ffbuild_unconfigure() {
    echo --disable-libgme
}
