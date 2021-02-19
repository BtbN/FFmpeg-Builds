#!/bin/bash

LIBUDFREAD_REPO="https://code.videolan.org/videolan/libudfread.git"
LIBUDFREAD_COMMIT="2ba6fa9a0acfcb1c65284d4e923be57982841b39"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBUDFREAD_REPO" "$LIBUDFREAD_COMMIT" libudfread
    cd libudfread

    ./bootstrap || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == win* ]]; then
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

    ln -s libudfread.pc "$FFBUILD_PREFIX"/lib/pkgconfig/udfread.pc

    cd ..
    rm -rf libudfread
}
