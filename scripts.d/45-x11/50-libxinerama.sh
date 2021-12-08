#!/bin/bash

LIBXINERAMA_REPO="https://gitlab.freedesktop.org/xorg/lib/libxinerama.git"
LIBXINERAMA_COMMIT="c5187f076d16601c15c59c5a2f05c0513d9f042b"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBXINERAMA_REPO" "$LIBXINERAMA_COMMIT" libxinerama
    cd libxinerama

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
