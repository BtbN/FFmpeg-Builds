#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/lib/libxv.git"
SCRIPT_COMMIT="e1cde54538060c4fd3a3d02e3d2e2b7e5da7bff9"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    [[ $ADDINS_STR == *4.4* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-shared
        --disable-static
        --with-pic
        --without-lint
    )

    if [[ $TARGET == linuxarm64 ]]; then
        myconf+=(
            --disable-malloc0returnsnull
        )
    fi

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

    gen-implib "$FFBUILD_PREFIX"/lib/{libXv.so.1,libXv.a}
    rm "$FFBUILD_PREFIX"/lib/libXv{.so*,.la}
}

ffbuild_configure() {
    echo --enable-xlib
}

ffbuild_unconfigure() {
    echo --disable-xlib
}
