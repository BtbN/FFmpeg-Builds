#!/bin/bash

AVISYNTH_REPO="https://github.com/AviSynth/AviSynthPlus.git"
AVISYNTH_COMMIT="3d76f69cfdc9ee98ab48a88303b00e87bcbd9706"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$AVISYNTH_REPO" "$AVISYNTH_COMMIT" avisynth
    cd avisynth

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DHEADERS_ONLY=ON ..
    make -j$(nproc)
    make install

    cd ..

    cmake -DSRC="${PWD}/avs_core/core/version.h.in" \
          -DDST="${FFBUILD_PREFIX}/include/avisynth/avs/version.h" \
          -DGIT="$(which git)" \
          -DREPO="${PWD}" \
          -P "${PWD}/avs_core/Version.cmake"
}

ffbuild_configure() {
    echo --enable-avisynth
}

ffbuild_unconfigure() {
    echo --disable-avisynth
}
