#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/fontconfig/fontconfig.git"
SCRIPT_COMMIT="a9fd30d226322f7f9b674a74d3782eea03c29453"

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

    local extra_opts=(
        --disable-docs
        --enable-libxml2
        --enable-iconv
    )

    if [[ $TARGET == linux* ]]; then
        extra_opts+=(
            --sysconfdir=/etc
            --localstatedir=/var
        )
    fi

    build_autotools "${extra_opts[@]}"

    rm -rf "$FFBUILD_DESTDIR"/{var,etc}
}

ffbuild_configure() {
    echo $(ffbuild_enable fontconfig)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable fontconfig)
}
