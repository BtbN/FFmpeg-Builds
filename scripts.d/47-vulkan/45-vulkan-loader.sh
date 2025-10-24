#!/bin/bash

SCRIPT_REPO="https://github.com/BtbN/Vulkan-Shim-Loader.git"
SCRIPT_COMMIT="9657ca8e395ef16c79b57c8bd3f4c1aebb319137"

SCRIPT_REPO2="https://github.com/KhronosGroup/Vulkan-Headers.git"
SCRIPT_COMMIT2="v1.4.329"
SCRIPT_TAGFILTER2="v?.*.*"

ffbuild_enabled() {
    [[ $ADDINS_STR == *4.4* ]] && return -1
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo "git-mini-clone \"$SCRIPT_REPO2\" \"$SCRIPT_COMMIT2\" Vulkan-Headers"
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DVULKAN_SHIM_IMPERSONATE=ON ..
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-vulkan
}

ffbuild_unconfigure() {
    echo --disable-vulkan
}
