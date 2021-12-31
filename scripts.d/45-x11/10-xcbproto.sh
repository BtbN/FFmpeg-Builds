#!/bin/bash

XCBPROTO_REPO="https://gitlab.freedesktop.org/xorg/proto/xcbproto.git"
XCBPROTO_COMMIT="70ca65fa35c3760661b090bc4b2601daa7a099b8"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$XCBPROTO_REPO" "$XCBPROTO_COMMIT" xcbproto
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
