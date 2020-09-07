#!/bin/bash

WAVPACK_REPO="https://github.com/dbry/WavPack"
WAVPACK_COMMIT="e4e8d191e8dd74cbdbeaef3232c16a7ef517e68d"

ffbuild_enabled() {
    return -1
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$WAVPACK_REPO" "$WAVPACK_COMMIT" wavpack
    cd wavpack

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --enable-legacy
        --with-pic
        --with-iconv
        --disable-man
        --enable-libcrypto
        --disable-apps
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
    rm -rf wavpack
}

ffbuild_configure() {
    echo --enable-libwavpack
}

ffbuild_unconfigure() {
    echo --disable-libwavpack
}
