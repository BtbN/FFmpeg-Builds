#!/bin/bash

# https://sourceforge.net/projects/freetype/files/freetype2/
FREETYPE_SRC="https://sourceforge.net/projects/freetype/files/freetype2/2.12.0/freetype-2.12.0.tar.xz/download"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir ft
    cd ft
    wget -O ft.tar.gz "$FREETYPE_SRC"
    tar xaf ft.tar.gz
    rm ft.tar.gz
    cd freetype*

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libfreetype
}

ffbuild_unconfigure() {
    echo --disable-libfreetype
}
