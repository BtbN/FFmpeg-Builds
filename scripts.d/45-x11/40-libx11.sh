#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/lib/libx11.git"
SCRIPT_COMMIT="76a930ca995e44be3b3b454a2d1b8844377527dc"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-shared
        --disable-static
        --with-pic
        --without-xmlto
        --without-fop
        --without-xsltproc
        --without-lint
        --disable-specs
        --enable-ipv6
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
    make install DESTDIR="$FFBUILD_DESTDIR"

    echo "Libs: -ldl" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/x11.pc

    gen-implib "$FFBUILD_DESTPREFIX"/lib/{libX11-xcb.so.1,libX11-xcb.a}
    gen-implib "$FFBUILD_DESTPREFIX"/lib/{libX11.so.6,libX11.a}
    rm "$FFBUILD_DESTPREFIX"/lib/libX11{,-xcb}{.so*,.la}
}
