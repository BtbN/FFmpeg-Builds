#!/bin/bash

LIBXRENDER_REPO="https://gitlab.freedesktop.org/xorg/lib/libxrender.git"
LIBXRENDER_COMMIT="bce0618839fc33f44edd8b5498b8e33d167806ff"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBXRENDER_REPO" "$LIBXRENDER_COMMIT" libxrender
    cd libxrender

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
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
