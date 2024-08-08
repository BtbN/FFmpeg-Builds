#!/bin/bash

SCRIPT_REPO="https://github.com/libgme/game-music-emu.git"
SCRIPT_COMMIT="b667f79dcee5c380541dc90630bb33931be378c7"

ffbuild_enabled() {
    return -1
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DCMAKE_DISABLE_FIND_PACKAGE_SDL2=1 -DBUILD_SHARED_LIBS=OFF -DENABLE_UBSAN=OFF ..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libgme
}

ffbuild_unconfigure() {
    echo --disable-libgme
}
