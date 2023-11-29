#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/lib/libpciaccess.git"
SCRIPT_COMMIT="c74d0a4b630f115e797cbb159ac13e0dc78f31f5"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR/$SELF"

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
