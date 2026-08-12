#!/bin/bash

SCRIPT_REPO="https://github.com/AviSynth/AviSynthPlus.git"
SCRIPT_COMMIT="de1d1fc0d69e6d308235491b24b8e9b26ac023ff"

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
    make VersionGen install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-avisynth
}

ffbuild_unconfigure() {
    echo --disable-avisynth
}
