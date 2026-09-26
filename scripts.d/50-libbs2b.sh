#!/bin/bash

SCRIPT_REPO="https://github.com/alexmarsev/libbs2b.git"
SCRIPT_COMMIT="5ca2d59888df047f1e4b028e3a2fd5be8b5a7277"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    default_dl .
}

ffbuild_dockerbuild() {
    sed -i '/PKG_CHECK_EXISTS.*sndfile/,/^])$/d' configure.ac
    sed -i 's/bin_PROGRAMS =.*/bin_PROGRAMS =/' src/Makefile.am
    sed -i '/bs2bconvert/d; /bs2bstream/d' src/Makefile.am

    autoreconf -isf

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --host="$FFBUILD_TOOLCHAIN"
        --disable-shared
        --enable-static
    )

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-libbs2b
}

ffbuild_unconfigure() {
    echo --disable-libbs2b
}
