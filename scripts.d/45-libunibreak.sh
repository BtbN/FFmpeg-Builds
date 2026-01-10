#!/bin/bash

SCRIPT_REPO="https://github.com/adah1972/libunibreak.git"
SCRIPT_COMMIT="e8760630e8b73cf0187fc781383c2be136aa462d"

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
