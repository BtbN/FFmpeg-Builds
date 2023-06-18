#!/bin/bash

SCRIPT_REPO="https://bitbucket.org/mpyne/game-music-emu.git"
SCRIPT_COMMIT="6cd4bdb69be304f58c9253fb08b8362f541b3b4b"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    to_df "RUN git clone \"$SCRIPT_REPO\" \"$SELF\""
    to_df "RUN git -C \"$SELF\" checkout \"$SCRIPT_COMMIT\""
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR/$SELF"

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
