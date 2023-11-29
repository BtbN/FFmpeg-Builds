#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/fontconfig/fontconfig.git"
SCRIPT_COMMIT="c53079fcc122de67a17e7056d03186039e2d4242"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR/$SELF"

    ./autogen.sh --noconf

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-docs
        --enable-libxml2
        --enable-iconv
        --disable-shared
        --enable-static
    )

    if [[ $TARGET == linux* ]]; then
        myconf+=(
            --sysconfdir=/etc
            --localstatedir=/var
            --host="$FFBUILD_TOOLCHAIN"
        )
    elif [[ $TARGET == win* ]]; then
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
    echo --enable-fontconfig
}

ffbuild_unconfigure() {
    echo --disable-fontconfig
}
