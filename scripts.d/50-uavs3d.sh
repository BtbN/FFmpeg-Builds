#!/bin/bash

UAVS3D_REPO="https://github.com/uavs3/uavs3d.git"
UAVS3D_COMMIT="1bd13916d524e2c1926d75fe99588428893f6987"

ffbuild_enabled() {
    [[ $ADDINS_STR == *4.3* ]] && return -1
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git clone "$UAVS3D_REPO" uavs3d
    cd uavs3d
    git checkout "$UAVS3D_COMMIT"

    mkdir build/linux
    cd build/linux

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=NO ../..
    make -j$(nproc)
    make install

    cd ../../..
    rm -rf uavs3d
}

ffbuild_configure() {
    echo --enable-libuavs3d
}

ffbuild_unconfigure() {
    [[ $ADDINS_STR == *4.3* ]] && return 0
    echo --disable-libuavs3d
}
