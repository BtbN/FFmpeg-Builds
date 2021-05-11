#!/bin/bash

ZIMG_REPO="https://github.com/sekrit-twc/zimg.git"
ZIMG_COMMIT="c8153de9aa33bf4a8b47678986e34662a532c05e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ZIMG_REPO" "$ZIMG_COMMIT" zimg
    cd zimg

    ./autogen.sh

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

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libzimg
}

ffbuild_unconfigure() {
    echo --disable-libzimg
}
