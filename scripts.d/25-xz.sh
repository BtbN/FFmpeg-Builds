#!/bin/bash

SCRIPT_REPO="https://github.com/xz-mirror/xz.git"
SCRIPT_COMMIT="8fd225a2c149f30aeac377e68eb5abf6b28300ad"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" xz
    cd xz

    ./autogen.sh --no-po4a

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-symbol-versions
        --disable-shared
        --enable-static
        --with-pic
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
    echo --enable-lzma
}

ffbuild_unconfigure() {
    echo --disable-lzma
}
