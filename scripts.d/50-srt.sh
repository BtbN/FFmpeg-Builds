#!/bin/bash

SRT_REPO="https://github.com/Haivision/srt.git"
SRT_COMMIT="74aff8287caf404cdcb7b33172412709a1a20821"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SRT_REPO" "$SRT_COMMIT" srt
    cd srt

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DENABLE_ENCRYPTION=ON -DENABLE_APPS=OFF ..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libsrt
}

ffbuild_unconfigure() {
    echo --disable-libsrt
}
