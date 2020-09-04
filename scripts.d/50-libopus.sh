#!/bin/bash

OPUS_REPO="https://github.com/xiph/opus.git"
OPUS_COMMIT="034c1b61a250457649d788bbf983b3f0fb63f02e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /root/opus.sh"
    to_df "RUN bash -c 'source /root/opus.sh && ffbuild_dockerbuild && rm /root/opus.sh'"
}

ffbuild_dockerbuild() {
    git clone "$OPUS_REPO" opus || return -1
    cd opus
    git checkout "$OPUS_COMMIT" || return -1

    ./autogen.sh || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
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
    rm -rf opus
}

ffbuild_configure() {
    echo --enable-libopus
}

ffbuild_unconfigure() {
    echo --disable-libopus
}
