#!/bin/bash

HEADERS_REPO="https://github.com/KhronosGroup/Vulkan-Headers.git"
HEADERS_VERSION="1.3.206"

ffbuild_enabled() {
    [[ $ADDINS_STR == *4.4* ]] && return -1
    return -1
}

ffbuild_dockerbuild() {
    git-mini-clone "$HEADERS_REPO" "v$HEADERS_VERSION" vkheaders
    cd vkheaders

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" ..
    make -j$(nproc)
    make install

    cat >"$FFBUILD_PREFIX"/lib/pkgconfig/vulkan.pc <<EOF
prefix=$FFBUILD_PREFIX
includedir=\${prefix}/include

Name: vulkan
Version: $HEADERS_VERSION
Description: Vulkan (Headers Only)
Cflags: -I\${includedir}
EOF
}

ffbuild_configure() {
    echo --enable-vulkan
}

ffbuild_unconfigure() {
    echo --disable-vulkan
}
