#!/bin/bash

LIBBLURAY_REPO="https://code.videolan.org/videolan/libbluray.git"
LIBBLURAY_COMMIT="311f09286e94565e1acb2e98bb7afaa903d6be13"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBBLURAY_REPO" "$LIBBLURAY_COMMIT" libbluray
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
