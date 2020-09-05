#!/bin/bash

LIBXML2_SRC="ftp://xmlsoft.org/libxml2/libxml2-2.9.10.tar.gz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    mkdir libxml2
    cd libxml2

    wget "$LIBXML2_SRC" -O libxml2.tar.gz || return -1
    tar xaf libxml2.tar.gz || return -1
    rm libxml2.tar.gz
    cd libxml2* || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-maintainer-mode
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

    ./autogen.sh "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ../..
    rm -rf libxml2
}

ffbuild_configure() {
    echo --enable-libxml2
}

ffbuild_unconfigure() {
    echo --disable-libxml2
}
