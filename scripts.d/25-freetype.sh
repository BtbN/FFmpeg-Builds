#!/bin/bash

FREETYPE_SRC="https://sourceforge.net/projects/freetype/files/freetype2/2.10.2/freetype-2.10.2.tar.xz/download"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    mkdir ft
    cd ft
    wget -O ft.tar.gz "$FREETYPE_SRC" || return -1
    tar xaf ft.tar.gz || return -1
    rm ft.tar.gz
    cd freetype*

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
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
    rm -rf ft
}

ffbuild_configure() {
    echo --enable-libfreetype
}

ffbuild_unconfigure() {
    echo --disable-libfreetype
}
