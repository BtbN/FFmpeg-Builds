#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/proto/xorgproto.git"
SCRIPT_COMMIT="9d5e1d1dc150e0eb3a562020f2069fad7ec9b3a9"

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
