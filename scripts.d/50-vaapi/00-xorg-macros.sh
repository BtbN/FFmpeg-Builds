#!/bin/bash

XORGMACROS_REPO="https://gitlab.freedesktop.org/xorg/util/macros.git"
XORGMACROS_COMMIT="b8766308d2f78bc572abe5198007cf7aeec9b761"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$XORGMACROS_REPO" "$XORGMACROS_COMMIT" xorg-macros
    cd xorg-macros

    autoreconf -i
    ./configure --prefix="/usr"
    make -j"$(nproc)"
    make install
}
