#!/bin/bash

SCRIPT_REPO="https://github.com/njh/twolame.git"
SCRIPT_COMMIT="90b694b6125dbe23a346bd5607a7fb63ad2785dc"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    NOCONFIGURE=1 ./autogen.sh
    touch doc/twolame.1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --with-pic
        --disable-shared
        --enable-static
        --disable-sndfile
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

    sed -i 's/Cflags:/Cflags: -DLIBTWOLAME_STATIC/' "$FFBUILD_PREFIX"/lib/pkgconfig/twolame.pc
}

ffbuild_configure() {
    echo --enable-libtwolame
}

ffbuild_unconfigure() {
    echo --disable-libtwolame
}

ffbuild_cflags() {
    echo -DLIBTWOLAME_STATIC
}
