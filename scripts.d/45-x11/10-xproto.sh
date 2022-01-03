#!/bin/bash

XPROTO_REPO="https://gitlab.freedesktop.org/xorg/proto/xorgproto.git"
XPROTO_COMMIT="914d8f5e0f469cd0416364dd008e9eea752bf703"

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
