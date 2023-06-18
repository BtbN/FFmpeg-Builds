#!/bin/bash

SCRIPT_VERSION="6.2.1"
SCRIPT_SHA512="c99be0950a1d05a0297d65641dd35b75b74466f7bf03c9e8a99895a3b2f9a0856cd17887738fa51cf7499781b65c049769271cbcb77d057d2e9f1ec52e07dd84"
SCRIPT_URL="https://ftp.gnu.org/gnu/gmp/gmp-${SCRIPT_VERSION}.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    to_df "RUN retry-tool check-wget gmp.tar.xz \"$SCRIPT_URL\" \"$SCRIPT_SHA512\""
}

ffbuild_dockerbuild() {
    tar xaf "$FFBUILD_DLDIR"/gmp.tar.xz
    cd "gmp-$SCRIPT_VERSION"

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
