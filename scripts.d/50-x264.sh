#!/bin/bash

X264_REPO="https://code.videolan.org/videolan/x264.git"
X264_COMMIT="db0d417728460c647ed4a847222a535b00d3dbcb"

ffbuild_enabled() {
    [[ $VARIANT == gpl* ]] || return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /root/x264.sh"
    to_df "RUN bash -c 'source /root/x264.sh && ffbuild_dockerbuild && rm /root/x264.sh'"
}

ffbuild_dockerbuild() {
    git clone "$X264_REPO" x264 || return -1
    pushd x264
    git switch "$X264_COMMIT" || return -1

    local myconf=(
        --disable-cli
        --enable-static
        --enable-pic
        --disable-lavf
        --disable-swscale
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

    popd
    rm -rf x264
}

ffbuild_configure() {
    echo --enable-libx264
}

ffbuild_cflags() {
    return 0
}

ffbuild_ldflags() {
    return 0
}
