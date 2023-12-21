#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/proto/xcbproto.git"
SCRIPT_COMMIT="1388374c7149114888a6a5cd6e9bf6ad4b42adf8"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
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
