#!/bin/bash

XZ_SRC="https://sourceforge.net/projects/lzmautils/files/xz-5.2.5.tar.xz/download"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir xz
    cd xz

    wget "$XZ_SRC" -O xz.tar.xz
    tar xaf xz.tar.xz
    rm xz.tar.xz
    cd xz*

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == win* ]]; then
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
    echo --enable-lzma
}

ffbuild_unconfigure() {
    echo --disable-lzma
}
