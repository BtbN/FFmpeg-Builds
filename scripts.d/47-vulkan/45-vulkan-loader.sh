#!/bin/bash

SCRIPT_REPO="https://github.com/KhronosGroup/Vulkan-Loader.git"
SCRIPT_COMMIT="v1.4.325"
SCRIPT_TAGFILTER="v?.*.*"

ffbuild_enabled() {
    [[ $ADDINS_STR == *4.4* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_TESTS=OFF -DBUILD_WERROR=OFF -DLOADER_CODEGEN=ON -DUSE_GAS=ON ..
    make -j$(nproc)
    make install

    if [[ $TARGET == win* ]]; then
        rm "$FFBUILD_PREFIX"/lib/libvulkan-1.dll.a
        "${FFBUILD_CROSS_PREFIX}"gendef "$FFBUILD_PREFIX"/bin/vulkan-1.dll
        "${FFBUILD_CROSS_PREFIX}"dlltool -d vulkan-1.def --output-delaylib "$FFBUILD_PREFIX"/lib/libvulkan-1.a
        rm "$FFBUILD_PREFIX"/bin/vulkan-1.dll

        sed -i -e 's/^\(Libs:\).*$/\1 -L${libdir} -lvulkan-1/' "$FFBUILD_PREFIX"/lib/pkgconfig/vulkan.pc
    elif [[ $TARGET == linux* ]]; then
        gen-implib "$FFBUILD_PREFIX"/lib/libvulkan{.so.1,.a}
        rm "$FFBUILD_PREFIX"/lib/libvulkan.so*

        sed -i -e 's/^\(Libs:\).*$/\1 -L${libdir} -lvulkan/' "$FFBUILD_PREFIX"/lib/pkgconfig/vulkan.pc
    else
        echo "Unsupported target"
        exit 1
    fi
}

ffbuild_configure() {
    echo --enable-vulkan
}

ffbuild_unconfigure() {
    echo --disable-vulkan
}
