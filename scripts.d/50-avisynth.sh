#!/bin/bash

AVISYNTH_REPO="https://github.com/AviSynth/AviSynthPlus.git"
AVISYNTH_COMMIT="c6d9cf4aa062a150995b8ef00eb8f46e7a2caec8"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return -1
}

ffbuild_dockerbuild() {
    git-mini-clone "$AVISYNTH_REPO" "$AVISYNTH_COMMIT" avisynth
    cd avisynth

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
