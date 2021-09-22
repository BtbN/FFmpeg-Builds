#!/bin/bash

XPROTO_REPO="https://gitlab.freedesktop.org/xorg/proto/xorgproto.git"
XPROTO_COMMIT="57acac1d4c7967f4661fb1c9f86f48f34a46c48d"

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
