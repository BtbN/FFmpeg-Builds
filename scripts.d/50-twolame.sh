#!/bin/bash

TWOLAME_SRC="https://sourceforge.net/projects/twolame/files/twolame/0.4.0/twolame-0.4.0.tar.gz/download"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    mkdir twolame
    cd twolame
    wget -O twolame.tar.gz "$TWOLAME_SRC" || return -1
    tar xaf twolame.tar.gz || return -1
    rm twolame.tar.gz
    cd twolame*

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --with-pic
        --disable-shared
        --enable-static
        --disable-sndfile
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

    sed -i 's/Cflags:/Cflags: -DLIBTWOLAME_STATIC/' "$FFBUILD_PREFIX"/lib/pkgconfig/twolame.pc || return -1

    cd ../..
    rm -rf twolame
}

ffbuild_configure() {
    echo --enable-libtwolame
}

ffbuild_unconfigure() {
    echo --disable-libtwolame
}

ffbuild_cflags() {
    echo -DLIBTWOLAME_STATIC
}
