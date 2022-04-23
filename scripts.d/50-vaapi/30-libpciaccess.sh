#!/bin/bash

LIBPCIACCESS_REPO="https://gitlab.freedesktop.org/xorg/lib/libpciaccess.git"
LIBPCIACCESS_COMMIT="22a93f8b9b4a79eefbdd0b2c412526f6141ac7a8"

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
        --enable-shared
        --disable-static
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

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAFS="$RAW_LDFLAGS"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    gen-implib "$FFBUILD_PREFIX"/lib/{libpciaccess.so.0,libpciaccess.a}
    rm "$FFBUILD_PREFIX"/lib/libpciaccess{.so*,.la}

    echo "Libs: -ldl" >> "$FFBUILD_PREFIX"/lib/pkgconfig/pciaccess.pc
}
