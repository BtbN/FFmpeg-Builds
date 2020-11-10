#!/bin/bash

SRT_REPO="https://github.com/Haivision/srt.git"
SRT_COMMIT="49dd2ec70d0ca64ac122c84dfc188b8abc1484f6"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$SRT_REPO" "$SRT_COMMIT" srt
    cd srt

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DENABLE_ENCRYPTION=ON -DENABLE_APPS=OFF .. || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ../..
    rm -rf srt
}

ffbuild_configure() {
    echo --enable-libsrt
}

ffbuild_unconfigure() {
    echo --disable-libsrt
}
