#!/bin/bash

UAVS3D_REPO="https://github.com/uavs3/uavs3d.git"
UAVS3D_COMMIT="e58e199ccc50163c20df114db7e3950295c3e2ed"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return -1
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
}

ffbuild_configure() {
    echo --enable-libuavs3d
}

ffbuild_unconfigure() {
    echo --disable-libuavs3d
}
