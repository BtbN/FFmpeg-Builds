#!/bin/bash

THEORA_REPO="https://github.com/xiph/theora.git"
THEORA_COMMIT="f98989ad7c3745d6cc4d24666e64046ff4a3f745"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$THEORA_REPO" "$THEORA_COMMIT" theora
    cd theora

    ./autogen.sh || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --disable-examples
        --disable-oggtest
        --disable-vorbistest
        --disable-spec
        --disable-doc
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
    rm -rf theora
}

ffbuild_configure() {
    echo --enable-libtheora
}

ffbuild_unconfigure() {
    echo --disable-libtheora
}
