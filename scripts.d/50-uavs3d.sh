#!/bin/bash

SCRIPT_REPO="https://github.com/uavs3/uavs3d.git"
SCRIPT_COMMIT="b8f8e215297ff98ee78162fdc3d9c52d16b113d5"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git clone "$SCRIPT_REPO" uavs3d
    cd uavs3d
    git checkout "$SCRIPT_COMMIT"

    mkdir build/linux
    cd build/linux

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCOMPILE_10BIT=1 -DBUILD_SHARED_LIBS=NO ../..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libuavs3d
}

ffbuild_unconfigure() {
    echo --disable-libuavs3d
}
