#!/bin/bash

# https://ftp.gnu.org/gnu/libiconv/
ICONV_SRC="https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    wget -O iconv.tar.gz "$ICONV_SRC"
    tar xaf iconv.tar.gz
    rm iconv.tar.gz
    cd libiconv*

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-extra-encodings
        --disable-shared
        --enable-static
        --with-pic
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
    echo --enable-iconv
}

ffbuild_unconfigure() {
    echo --disable-iconv
}
