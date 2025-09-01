#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/fontconfig/fontconfig.git"
SCRIPT_COMMIT="22cbfff10da57dc56a497387d16478db064eb210"

ffbuild_depends() {
    echo base
    echo libxml2
    echo libiconv
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    # The version-detection here fails for Debian-Versions of libtoolize, so it needs a bit of help
    sed -i -e 's/libtool_version=.*/libtool_version=2.5/g' ./autogen.sh

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
    make install DESTDIR="$FFBUILD_DESTDIR"

    rm -rf "$FFBUILD_DESTDIR"/{var,etc}
}

ffbuild_configure() {
    echo --enable-fontconfig
}

ffbuild_unconfigure() {
    echo --disable-fontconfig
}
