#!/bin/bash

LIBXCB_REPO="https://gitlab.freedesktop.org/xorg/lib/libxcb.git"
LIBXCB_COMMIT="21414e7c447f18224c577ed5e32bd5d6e45c44f9"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBXCB_REPO" "$LIBXCB_COMMIT" libxcb
    cd libxcb

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --disable-devel-docs
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

ffbuild_configure() {
    echo --enable-libxcb
}

ffbuild_unconfigure() {
    echo --disable-libxcb
}
