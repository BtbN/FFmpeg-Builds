#!/bin/bash

THEORA_REPO="https://github.com/xiph/theora.git"
THEORA_COMMIT="7180717276af1ebc7da15c83162d6c5d6203aabf"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$THEORA_REPO" "$THEORA_COMMIT" theora
    cd theora

    ./autogen.sh

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

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libtheora
}

ffbuild_unconfigure() {
    echo --disable-libtheora
}
