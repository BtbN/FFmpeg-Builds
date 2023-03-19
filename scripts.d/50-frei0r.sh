#!/bin/bash

SCRIPT_REPO="https://github.com/dyne/frei0r.git"
SCRIPT_COMMIT="3e1234b9f2ba86b1deebdd1034735e12d706c095"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $ADDINS_STR == *4.4* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" frei0r
    cd frei0r

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" ..

    mkdir -p "$FFBUILD_PREFIX"/lib/pkgconfig
    cp frei0r.pc "$FFBUILD_PREFIX"/lib/pkgconfig

    mkdir -p "$FFBUILD_PREFIX"/include
    cp ../include/frei0r.h "$FFBUILD_PREFIX"/include

    cat frei0r.pc
}

ffbuild_configure() {
    echo --enable-frei0r
}

ffbuild_unconfigure() {
    echo --disable-frei0r
}
