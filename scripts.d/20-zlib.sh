#!/bin/bash

SCRIPT_REPO="https://github.com/madler/zlib.git"
SCRIPT_COMMIT="09a1572aa624e5ddb6c075dc013880de70b1b9b9"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --static
    )

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-zlib
}

ffbuild_unconfigure() {
    echo --disable-zlib
}
