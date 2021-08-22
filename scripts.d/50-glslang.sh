#!/bin/bash

GLSLANG_REPO="https://github.com/KhronosGroup/glslang.git"
GLSLANG_COMMIT="a4599ef7561abed83d45bab4c7492daeceef92a5"

ffbuild_enabled() {
    # Pointless without Vulkan
    [[ $TARGET == linux* ]] && return -1

    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$GLSLANG_REPO" "$GLSLANG_COMMIT" glslang
    cd glslang

    python3 ./update_glslang_sources.py

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=OFF -DBUILD_EXTERNAL=ON -DBUILD_TESTING=OFF -DENABLE_CTEST=OFF -DENABLE_HLSL=ON -DENABLE_GLSLANG_BINARIES=OFF ..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libglslang
}

ffbuild_unconfigure() {
    echo --disable-libglslang
}
