#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/lib/libxtrans.git"
SCRIPT_COMMIT="3309c75906a56de86607f59481304b3a2812162f"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" libxtrans
    cd libxtrans

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --without-xmlto
        --without-fop
        --without-xsltproc
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

    cp -r "$FFBUILD_PREFIX"/share/aclocal/. /usr/share/aclocal
}
