#!/bin/bash

LIBX11_REPO="https://gitlab.freedesktop.org/xorg/lib/libx11.git"
LIBX11_COMMIT="e92efc63acd7b377faa9e534f4bf52aaa86be2a9"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBX11_REPO" "$LIBX11_COMMIT" libx11
    cd libx11

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --without-xmlto
        --without-fop
        --without-xsltproc
        --without-lint
        --disable-specs
        --enable-ipv6
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

    echo "Libs.private: -ldl" >> "$FFBUILD_PREFIX"/lib/pkgconfig/x11.pc
}
