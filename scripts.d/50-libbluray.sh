#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/libbluray.git"
SCRIPT_COMMIT="8f26777b1ce124ff761f80ef52d6be10bcea323e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" libbluray
    cd libbluray

    ./bootstrap

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --disable-doxygen-doc
        --disable-doxygen-dot
        --disable-doxygen-html
        --disable-doxygen-ps
        --disable-doxygen-pdf
        --disable-examples
        --disable-bdjava-jar
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
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
    echo --enable-libbluray
}

ffbuild_unconfigure() {
    echo --disable-libbluray
}
