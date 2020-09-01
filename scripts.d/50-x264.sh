#!/bin/bash

X264_REPO="https://code.videolan.org/videolan/x264.git"
X264_COMMIT="db0d417728460c647ed4a847222a535b00d3dbcb"

ffbuild_relevant() {
    [[ $VARIANT == gpl ]] || return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /root/x264.sh"
    to_df "RUN bash -c 'source /root/x264.sh && ffbuild_dockerbuild'"
}

ffbuild_dockerbuild() {
    git clone "$X264_REPO" x264 || return -1
    pushd x264
    git checkout "$X264_COMMIT" || return -1

    if [[ $TARGET == win64 ]]; then
        ./configure --disable-cli --enable-static --enable-pic \
                    --disable-lavf --disable-swscale \
                    --host=x86_64-w64-mingw32 --cross-prefix=x86_64-w64-mingw32- \
                    --prefix="$FFPREFIX" || return -1
    else
        echo "Unknown target"
        return -1
    fi

    make -j$(nproc) || return -1
    make install || return -1

    popd
    rm -rf x264
}
