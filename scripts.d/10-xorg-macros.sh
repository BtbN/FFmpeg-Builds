#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/xorg/util/macros.git"
SCRIPT_COMMIT="ea1e15a4909ac8b03b2c5a08ac3810b385985157"

ffbuild_depends() {
    return 0
}

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --link --from=${SELFLAYER} \$FFBUILD_DESTPREFIX/. \$FFBUILD_PREFIX"
    to_df "COPY --link --from=${SELFLAYER} \$FFBUILD_DESTPREFIX/share/aclocal/. /usr/share/aclocal"
}

ffbuild_dockerbuild() {
    autoreconf -i
    ./configure --prefix="$FFBUILD_PREFIX"
    make -j"$(nproc)"
    make install DESTDIR="$FFBUILD_DESTDIR"
}
