#!/bin/bash

XORGMACROS_REPO="https://gitlab.freedesktop.org/xorg/util/macros.git"
XORGMACROS_COMMIT="b8766308d2f78bc572abe5198007cf7aeec9b761"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --from=${SELFLAYER} \$FFBUILD_PREFIX/. \$FFBUILD_PREFIX"
    to_df "COPY --from=${SELFLAYER} \$FFBUILD_PREFIX/share/aclocal/. /usr/share/aclocal"
}

ffbuild_dockerbuild() {
    git-mini-clone "$XORGMACROS_REPO" "$XORGMACROS_COMMIT" xorg-macros
    cd xorg-macros

    autoreconf -i
    ./configure --prefix="$FFBUILD_PREFIX"
    make -j"$(nproc)"
    make install
}
