#!/bin/bash

LIBSR_REPO="https://github.com/libsndfile/libsamplerate.git"
LIBSR_COMMIT="c28af3dece9b149341ec8020259fc46b9a314740"

ffbuild_enabled() {
    # Dependency of GPL-Only librubberband
    [[ $VARIANT == gpl* ]] || return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBSR_REPO" "$LIBSR_COMMIT" libsr
    cd libsr

    mkdir build
    cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=NO -DBUILD_TESTING=NO -DLIBSAMPLERATE_EXAMPLES=OFF -DLIBSAMPLERATE_INSTALL=YES ..
    make -j$(nproc)
    make install

    cd ../..
    rm -rf libsr
}
