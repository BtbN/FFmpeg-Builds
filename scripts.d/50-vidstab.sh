#!/bin/bash

VIDSTAB_REPO="https://github.com/georgmartius/vid.stab.git"
VIDSTAB_COMMIT="f9166e9b082242b622b5b456ef80cbdbd4042826"

ffbuild_enabled() {
    [[ $VARIANT == gpl* ]] || return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$VIDSTAB_REPO" "$VIDSTAB_COMMIT" vidstab
    cd vidstab

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=OFF ..
    make -j$(nproc)
    make install

    cd ../..
    rm -rf vidstab
}

ffbuild_configure() {
    echo --enable-libvidstab
}

ffbuild_unconfigure() {
    echo --disable-libvidstab
}
