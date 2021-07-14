#!/bin/bash

LIBX11_REPO="https://gitlab.freedesktop.org/xorg/lib/libx11.git"
LIBX11_COMMIT="d01d23374107f6fc55511f02559cf75be7bdf448"

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
}
