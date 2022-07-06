#!/bin/bash

LIBXFIXES_REPO="https://gitlab.freedesktop.org/xorg/lib/libxfixes.git"
LIBXFIXES_COMMIT="6fe3bd64dd82f704ed91478acb4c99ab5c00be16"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBXFIXES_REPO" "$LIBXFIXES_COMMIT" libxfixes
    cd libxfixes

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-shared
        --disable-static
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

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAFS="$RAW_LDFLAGS"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    gen-implib "$FFBUILD_PREFIX"/lib/{libXfixes.so.3,libXfixes.a}
    rm "$FFBUILD_PREFIX"/lib/libXfixes{.so*,.la}
}
