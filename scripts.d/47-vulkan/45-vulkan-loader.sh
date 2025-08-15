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
    make install DESTDIR="$FFBUILD_DESTDIR"

    if [[ $TARGET == win* ]]; then
        if [[ $CC == *clang* ]]; then
            echo 'Libs.private: -Wl,-delayload,vulkan-1.dll' >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/vulkan.pc
        else
            rm "$FFBUILD_DESTPREFIX"/lib/libvulkan-1.dll.a
            "$GENDEF" "$FFBUILD_DESTPREFIX"/bin/vulkan-1.dll
            "$DLLTOOL" -d vulkan-1.def --output-delaylib "$FFBUILD_DESTPREFIX"/lib/libvulkan-1.a
            rm "$FFBUILD_DESTPREFIX"/bin/vulkan-1.dll
        fi

        sed -i -e 's/^\(Libs:\).*$/\1 -L${libdir} -lvulkan-1/' "$FFBUILD_DESTPREFIX"/lib/pkgconfig/vulkan.pc
    elif [[ $TARGET == linux* ]]; then
        gen-implib "$FFBUILD_DESTPREFIX"/lib/libvulkan{.so.1,.a}
        rm "$FFBUILD_DESTPREFIX"/lib/libvulkan.so*

        sed -i -e 's/^\(Libs:\).*$/\1 -L${libdir} -lvulkan/' "$FFBUILD_DESTPREFIX"/lib/pkgconfig/vulkan.pc
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
