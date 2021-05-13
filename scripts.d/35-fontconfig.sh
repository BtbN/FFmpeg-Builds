#!/bin/bash

FONTCONFIG_SRC="https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.93.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir fc
    cd fc

    wget "$FONTCONFIG_SRC" -O fc.tar.gz
    tar xaf fc.tar.gz
    rm fc.tar.gz
    cd fontconfig*

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-docs
        --enable-libxml2
        --enable-iconv
        --disable-shared
        --enable-static
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    elif [[ $TARGET != linux* ]]; then
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    sed -i 's/Libs.private:/Libs.private: -lintl/' "$FFBUILD_PREFIX"/lib/pkgconfig/fontconfig.pc
}

ffbuild_configure() {
    echo --enable-fontconfig
}

ffbuild_unconfigure() {
    echo --disable-fontconfig
}
