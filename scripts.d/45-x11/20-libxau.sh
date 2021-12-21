#!/bin/bash

LIBXAU_REPO="https://gitlab.freedesktop.org/xorg/lib/libxau.git"
LIBXAU_COMMIT="d9443b2c57b512cfb250b35707378654d86c7dea"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBXAU_REPO" "$LIBXAU_COMMIT" libxau
    cd libxau

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

    gen-implib "$FFBUILD_PREFIX"/lib/{libXau.so.6,libXau.a}
    rm "$FFBUILD_PREFIX"/lib/libXau{.so*,.la}
}
