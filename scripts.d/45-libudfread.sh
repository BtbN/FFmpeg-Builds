#!/bin/bash

LIBUDFREAD_REPO="https://code.videolan.org/videolan/libudfread.git"
LIBUDFREAD_COMMIT="d091bf5f7de554fbd1e61b965a88bc1a6779b572"

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

    ln -s udfread.pc "$FFBUILD_PREFIX"/lib/pkgconfig/libudfread.pc

    cd ..
    rm -rf libudfread
}
