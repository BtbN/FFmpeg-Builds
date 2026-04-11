#!/bin/bash

SCRIPT_REPO="https://github.com/adah1972/libunibreak.git"
SCRIPT_COMMIT="3ce4bfa3129ff3738046a44a6db533d2ce25af2b"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    bash ./bootstrap

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
    make install DESTDIR="$FFBUILD_DESTDIR"
}
