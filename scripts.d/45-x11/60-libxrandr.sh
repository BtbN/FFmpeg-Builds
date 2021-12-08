#!/bin/bash

LIBXRANDR_REPO="https://gitlab.freedesktop.org/xorg/lib/libxrandr.git"
LIBXRANDR_COMMIT="55dcda4518eda8ae03ef25ea29d3c994ad71eb0a"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBXRANDR_REPO" "$LIBXRANDR_COMMIT" libxrandr
    cd libxrandr

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == linux* ]]; then
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
