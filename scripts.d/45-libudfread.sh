#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/libudfread.git"
SCRIPT_COMMIT="139a2194525f2745b98a98e4d8fa627d07440176"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    ./bootstrap

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
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
    make install DESTDIR="$FFBUILD_DESTDIR"

    ln -s libudfread.pc "$FFBUILD_DESTPREFIX"/lib/pkgconfig/udfread.pc
}
