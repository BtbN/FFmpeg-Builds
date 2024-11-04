#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/util/macros.git"
SCRIPT_COMMIT="b9f5184ed2e9c019d867ced99020e22abb7c2e53"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --link --from=${SELFLAYER} \$FFBUILD_PREFIX/. \$FFBUILD_PREFIX"
    to_df "COPY --link --from=${SELFLAYER} \$FFBUILD_PREFIX/share/aclocal/. /usr/share/aclocal"
}

ffbuild_dockerbuild() {
    autoreconf -i
    ./configure --prefix="$FFBUILD_PREFIX"
    make -j"$(nproc)"
    make install
}
