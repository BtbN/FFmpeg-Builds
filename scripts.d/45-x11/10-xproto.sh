#!/bin/bash

XPROTO_REPO="https://gitlab.freedesktop.org/xorg/proto/xorgproto.git"
XPROTO_COMMIT="8c8bbb903410e39140727867a26bbe501f77de8f"

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
