#!/bin/bash

SCRIPT_REPO="https://gmplib.org/repo/gmp/"
SCRIPT_HGREV="cc75cab76738"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    hg clone -r "$SCRIPT_HGREV" -u "$SCRIPT_HGREV" "$SCRIPT_REPO" gmp
    cd gmp

    ./.bootstrap

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-maintainer-mode
        --disable-shared
        --enable-static
        --with-pic
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
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-gmp
}

ffbuild_unconfigure() {
    echo --disable-gmp
}
