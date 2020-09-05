#!/bin/bash

FONTCONFIG_SRC="https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.92.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    mkdir fc
    cd fc

    wget "$FONTCONFIG_SRC" -O fc.tar.gz || return -1
    tar xaf fc.tar.gz || return -1
    rm fc.tar.gz
    cd fontconfig* || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-libxml2
        --disable-shared
        --enable-static
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ../..
    rm -rf fc
}

ffbuild_configure() {
    echo --enable-fontconfig
}

ffbuild_unconfigure() {
    echo --disable-fontconfig
}
