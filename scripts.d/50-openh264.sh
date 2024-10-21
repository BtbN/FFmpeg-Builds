#!/bin/bash

SCRIPT_REPO="https://github.com/cisco/openh264.git"
SCRIPT_COMMIT="3668daf135dea7d18737b01ce32774a7a2ffba32"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    local myconf=(
        PREFIX="$FFBUILD_PREFIX"
        INCLUDE_PREFIX="$FFBUILD_PREFIX"/include/wels
        BUILDTYPE=Release
        DEBUGSYMBOLS=False
        LIBDIR_NAME=lib
        CC="$CC"
        CXX="$CXX"
        AR="$AR"
    )

    if [[ $TARGET == win32 ]]; then
        myconf+=(
            OS=mingw_nt
            ARCH=i686
        )
    elif [[ $TARGET == win64 ]]; then
        myconf+=(
            OS=mingw_nt
            ARCH=x86_64
        )
    elif [[ $TARGET == winarm64 ]]; then
        myconf+=(
            OS=mingw_nt
            ARCH=aarch64
        )
    elif [[ $TARGET == linux64 ]]; then
        myconf+=(
            OS=linux
            ARCH=x86_64
        )
    elif [[ $TARGET == linuxarm64 ]]; then
        myconf+=(
            OS=linux
            ARCH=aarch64
        )
    else
        echo "Unknown target"
        return -1
    fi

    make -j$(nproc) "${myconf[@]}" install-static
}

ffbuild_configure() {
    echo --enable-libopenh264
}

ffbuild_unconfigure() {
    echo --disable-libopenh264
}
