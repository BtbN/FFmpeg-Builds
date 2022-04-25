#!/bin/bash

ARIBB24_REPO="https://github.com/nkoriyama/aribb24.git"
ARIBB24_COMMIT="5e9be272f96e00f15a2f3c5f8ba7e124862aec38"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ARIBB24_REPO" "$ARIBB24_COMMIT" aribb24
    cd aribb24

    autoreconf -fi

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
    echo --enable-libaribb24
}

ffbuild_unconfigure() {
    echo --disable-libaribb24
}
