#!/bin/bash

LIBUDFREAD_REPO="https://code.videolan.org/videolan/libudfread.git"
LIBUDFREAD_COMMIT="a35513813819efadca82c4b90edbe1407b1b9e05"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBUDFREAD_REPO" "$LIBUDFREAD_COMMIT" libudfread
    cd libudfread

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
    make install

    ln -s libudfread.pc "$FFBUILD_PREFIX"/lib/pkgconfig/udfread.pc
}
