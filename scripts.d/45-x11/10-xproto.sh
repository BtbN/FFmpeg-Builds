#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/proto/xorgproto.git"
SCRIPT_COMMIT="68de489ec6c2fb6f8cfc47b0bba7edd0f9942f17"

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
