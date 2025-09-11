#!/bin/bash

SCRIPT_REPO="https://github.com/dyne/frei0r.git"
SCRIPT_COMMIT="e7dd4f600b9e1ae15e9e7be1b5f4464d0b1bfda8"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $ADDINS_STR == *4.4* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" ..

    mkdir -p "$FFBUILD_DESTPREFIX"/lib/pkgconfig
    cp frei0r.pc "$FFBUILD_DESTPREFIX"/lib/pkgconfig

    mkdir -p "$FFBUILD_DESTPREFIX"/include
    cp ../include/frei0r.h "$FFBUILD_DESTPREFIX"/include
}

ffbuild_configure() {
    echo --enable-frei0r
}

ffbuild_unconfigure() {
    echo --disable-frei0r
}
