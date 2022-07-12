#!/bin/bash

SCRIPT_REPO="https://github.com/sekrit-twc/zimg.git"
SCRIPT_COMMIT="51c3c7f750c2af61955377faad56e3ba1b03589f"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" zimg
    cd zimg

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
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
    echo --enable-libzimg
}

ffbuild_unconfigure() {
    echo --disable-libzimg
}
