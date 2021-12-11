#!/bin/bash

ALSALIB_REPO="https://github.com/alsa-project/alsa-lib.git"
ALSALIB_COMMIT="1454b5f118a3b92663923fe105daecfeb7e20f1b"

ffbuild_enabled() {
    [[ $TARGET == linux* ]] || return 1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ALSALIB_REPO" "$ALSALIB_COMMIT" alsalib
    cd alsalib

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --with-configdir="/usr/share/alsa"
        --disable-shared
        --enable-static
        --with-pic
        --without-debug
        --without-versioned
        --disable-old-symbols
        --disable-python
        --disable-topology
        --disable-alisp
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

    rm -rf "$FFBUILD_PREFIX"/{bin/aserver,share/alsa}
}

ffbuild_configure() {
    echo --enable-alsa
}

ffbuild_unconfigure() {
    echo --disable-alsa
}
