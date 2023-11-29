#!/bin/bash

SCRIPT_REPO="https://github.com/KhronosGroup/Vulkan-Headers.git"
SCRIPT_COMMIT="v1.3.271"
SCRIPT_TAGFILTER="v?.*.*"

ffbuild_enabled() {
    [[ $ADDINS_STR == *4.4* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR/$SELF"

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" ..
    make -j$(nproc)
    make install

    cat >"$FFBUILD_PREFIX"/lib/pkgconfig/vulkan.pc <<EOF
prefix=$FFBUILD_PREFIX
includedir=\${prefix}/include

Name: vulkan
Version: ${SCRIPT_COMMIT:1}
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
