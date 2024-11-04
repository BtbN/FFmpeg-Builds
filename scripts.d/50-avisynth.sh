#!/bin/bash

SCRIPT_REPO="https://github.com/AviSynth/AviSynthPlus.git"
SCRIPT_COMMIT="b7dbabd0c6bd2069e2bb2d31c127622a8b919d06"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    # their version check is insistant on a tag to exist, so make one
    git tag -a ffbuild -m "FFbuild Version"

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DHEADERS_ONLY=ON ..
    make -j$(nproc)
    make VersionGen install
}

ffbuild_configure() {
    echo --enable-avisynth
}

ffbuild_unconfigure() {
    echo --disable-avisynth
}
