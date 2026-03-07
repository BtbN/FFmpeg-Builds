#!/bin/bash

SCRIPT_REPO="https://github.com/timothytylee/libgsm.git"
SCRIPT_COMMIT="98f1708fb5e06a0dfebd58a3b40d610823db9715"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    make CC="$CC" AR="$AR" RANLIB="$RANLIB" lib/libgsm.a -j$(nproc)

    mkdir -p "$FFBUILD_DESTPREFIX"/lib "$FFBUILD_DESTPREFIX"/include/gsm
    cp lib/libgsm.a "$FFBUILD_DESTPREFIX"/lib/
    cp inc/gsm.h "$FFBUILD_DESTPREFIX"/include/gsm/
}

ffbuild_configure() {
    echo --enable-libgsm
}

ffbuild_unconfigure() {
    echo --disable-libgsm
}
