#!/bin/bash

XVID_SRC="https://downloads.xvid.com/downloads/xvidcore-1.3.7.tar.gz"

ffbuild_enabled() {
    [[ $VARIANT == gpl* ]] || return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    mkdir xvid
    cd xvid
    wget -O xvid.tar.gz "$XVID_SRC" || return -1
    tar xaf xvid.tar.gz || return -1
    rm xvid.tar.gz
    cd xvid*

    cd build/generic

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
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

    rm "$FFBUILD_PREFIX"/{bin/xvidcore.dll,lib/xvidcore.dll.a}
    mv "$FFBUILD_PREFIX"/lib/{,lib}xvidcore.a

    cd ../../../..
    rm -rf xvid
}

ffbuild_configure() {
    echo --enable-libxvid
}

ffbuild_unconfigure() {
    echo --disable-libxvid
}
