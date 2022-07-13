#!/bin/bash

SCRIPT_REPO="https://github.com/dyne/frei0r.git"
SCRIPT_COMMIT="a9d15ff07e130baf3408da6e1f1b22f82e7c62b6"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $ADDINS_STR == *4.4* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" frei0r
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
