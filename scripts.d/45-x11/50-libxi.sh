#!/bin/bash

LIBXI_REPO="https://gitlab.freedesktop.org/xorg/lib/libxi.git"
LIBXI_COMMIT="f24d7f43ab4d97203e60677a3d42e11dbc80c8b4"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBXI_REPO" "$LIBXI_COMMIT" libxi
    cd libxi

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
