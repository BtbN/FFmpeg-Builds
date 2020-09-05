#!/bin/bash

ZLIB_SRC="https://zlib.net/zlib-1.2.11.tar.gz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    mkdir zlib
    cd zlib

    wget "$ZLIB_SRC" -O zlib.tar.gz || return -1
    tar xaf zlib.tar.gz || return -1
    rm zlib.tar.gz
    cd zlib* || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --static
    )

    if [[ $TARGET == win* ]]; then
        export CC="${FFBUILD_CROSS_PREFIX}gcc"
        export AR="${FFBUILD_CROSS_PREFIX}ar"
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ../..
    rm -rf zlib
}

ffbuild_configure() {
    echo --enable-zlib
}

ffbuild_unconfigure() {
    echo --disable-zlib
}
