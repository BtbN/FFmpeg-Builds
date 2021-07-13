#!/bin/bash

LIBPCIACCESS_REPO="https://gitlab.freedesktop.org/xorg/lib/libpciaccess.git"
LIBPCIACCESS_COMMIT="9c01fdd7c02d8b9b5003e659ebca0b3643bd47c4"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBPCIACCESS_REPO" "$LIBPCIACCESS_COMMIT" libpciaccess
    cd libpciaccess

    autoreconf -fi

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --with-zlib
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
