#!/bin/bash

XPROTO_REPO="https://gitlab.freedesktop.org/xorg/proto/xorgproto.git"
XPROTO_COMMIT="74255ccfd895e70156c45a2c51174c852b64bc71"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$XPROTO_REPO" "$XPROTO_COMMIT" xproto
    cd xproto

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
