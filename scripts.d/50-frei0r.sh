#!/bin/bash

FREI0R_REPO="https://github.com/dyne/frei0r.git"
FREI0R_COMMIT="6a576f4538992bbbe88eba1e773d6144d22eb3ca"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $ADDINS_STR == *4.4* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$FREI0R_REPO" "$FREI0R_COMMIT" frei0r
    cd frei0r

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --enable-cpuflags
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -C include -j$(nproc)
    make -C include install
    make install-pkgconfigDATA
}

ffbuild_configure() {
    echo --enable-frei0r
}

ffbuild_unconfigure() {
    echo --disable-frei0r
}
