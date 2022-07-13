#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/proto/xcbproto.git"
SCRIPT_COMMIT="0fc6197034c49d9fdf5607cae201f1ac3270e7de"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" xcbproto
    cd xcbproto

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
