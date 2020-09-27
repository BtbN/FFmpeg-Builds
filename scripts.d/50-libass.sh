#!/bin/bash

ASS_REPO="https://github.com/libass/libass.git"
ASS_COMMIT="962b1a39c10d64f1ddf7886d4c59ce45e576d55a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$ASS_REPO" "$ASS_COMMIT" ass
    cd ass

    ./autogen.sh || return -1

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

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ..
    rm -rf ass
}

ffbuild_configure() {
    echo --enable-libass
}

ffbuild_unconfigure() {
    echo --disable-libass
}
