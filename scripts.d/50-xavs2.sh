#!/bin/bash

XAVS2_REPO="https://github.com/pkuvcl/xavs2.git"
XAVS2_COMMIT="eae1e8b9d12468059bdd7dee893508e470fa83d8"

ffbuild_enabled() {
    [[ $VARIANT == gpl* ]] || return -1
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git clone "$XAVS2_REPO" xavs2
    cd xavs2
    git checkout "$XAVS2_COMMIT"
    cd build/linux

    local myconf=(
        --disable-cli
        --enable-static
        --enable-pic
        --disable-avs
        --disable-swscale
        --disable-lavf
        --disable-ffms
        --disable-gpac
        --disable-lsmash
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
            --cross-prefix="$FFBUILD_CROSS_PREFIX"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ../../..
    rm -rf xavs2
}

ffbuild_configure() {
    echo --enable-libxavs2
}

ffbuild_unconfigure() {
    echo --disable-libxavs2
}
