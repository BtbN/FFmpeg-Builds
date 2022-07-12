#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/proto/xcbproto.git"
SCRIPT_COMMIT="b69b997c11d863d63ee053a0ff4d62957d8ab389"

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
