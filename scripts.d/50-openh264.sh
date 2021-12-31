#!/bin/bash

OPENH264_REPO="https://github.com/cisco/openh264.git"
OPENH264_COMMIT="a8094d85f5dd5ef112fbcfec2974e18fd0387c0b"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$OPENH264_REPO" "$OPENH264_COMMIT" openh264
    cd openh264

    local myconf=(
        PREFIX="$FFBUILD_PREFIX"
        BUILDTYPE=Release
        DEBUGSYMBOLS=False
        LIBDIR_NAME=lib
        CC="$FFBUILD_CROSS_PREFIX"gcc
        CXX="$FFBUILD_CROSS_PREFIX"g++
        AR="$FFBUILD_CROSS_PREFIX"ar
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
    elif [[ $TARGET == linux64 ]]; then
        myconf+=(
            OS=linux
            ARCH=x86_64
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
