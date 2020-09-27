#!/bin/bash

GLSLANG_REPO="https://github.com/KhronosGroup/glslang.git"
GLSLANG_COMMIT="d0e7ed37fc4ee17948a8a6597ce95a4fdab2b769"

ffbuild_enabled() {
    [[ $ADDINS_STR != *vulkan* ]] && return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$GLSLANG_REPO" "$GLSLANG_COMMIT" glslang
    cd glslang

    python3 ./update_glslang_sources.py

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=OFF -DBUILD_EXTERNAL=ON -DBUILD_TESTING=OFF -DENABLE_CTEST=OFF -DENABLE_HLSL=ON -DENABLE_GLSLANG_BINARIES=OFF ..
    make -j$(nproc)
    make install

    cd ../..
    rm -rf glslang
}

ffbuild_configure() {
    echo --enable-libglslang
}

ffbuild_unconfigure() {
    echo --disable-libglslang
}
