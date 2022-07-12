#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/util/macros.git"
SCRIPT_COMMIT="0326ba3c4caa34116c0e7e4af98661858cf25d1c"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --from=${SELFLAYER} \$FFBUILD_PREFIX/. \$FFBUILD_PREFIX"
    to_df "COPY --from=${SELFLAYER} \$FFBUILD_PREFIX/share/aclocal/. /usr/share/aclocal"
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" xorg-macros
    cd xorg-macros

    autoreconf -i
    ./configure --prefix="$FFBUILD_PREFIX"
    make -j"$(nproc)"
    make install
}
