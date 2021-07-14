#!/bin/bash

XCBPROTO_REPO="https://gitlab.freedesktop.org/xorg/proto/xcbproto.git"
XCBPROTO_COMMIT="496e3ce329c3cc9b32af4054c30fa0f306deb007"

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
