#!/bin/bash

SCRIPT_REPO="https://github.com/v-novaltd/LCEVCdec.git"
SCRIPT_COMMIT="b2ec81729399eab4f1f4c706837a0fb7f3d72c37"

ffbuild_enabled() {
    (( $(ffbuild_ffver) >= 800 )) || return -1
    [[ $TARGET != winarm* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build
    cd build

    cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=NO -DVN_SDK_EXECUTABLES=OFF -DVN_SDK_SAMPLE_SOURCE=OFF -DVN_SDK_TRACING=OFF -DVN_SDK_METRICS=OFF -DVN_SDK_SYSTEM_INSTALL=ON \
        -DVN_SDK_PIPELINE_LEGACY=OFF -DVN_SDK_PIPELINE_VULKAN=OFF -DPC_LIBS_PRIVATE="Libs.private: -lstdc++" ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    rm -rf rm "$FFBUILD_DESTPREFIX"/share
}

ffbuild_configure() {
    echo --enable-liblcevc-dec
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) >= 701 )) || return 0
    echo --disable-liblcevc-dec
}
