#!/bin/bash

SCRIPT_REPO="https://github.com/saindriches/davs2.git"
SCRIPT_COMMIT="f50435051b72c168c2b566c544e27fcff71ba61a"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $TARGET == win32 ]] && return -1
    # davs2 aarch64 support is broken
    [[ $TARGET == *arm64 ]] && return -1
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo "git fetch --unshallow"
}

ffbuild_dockerbuild() {
    cd build/linux

    local myconf=(
        --disable-cli
        --enable-pic
        --bit-depth=10
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
            --cross-prefix="$FFBUILD_CROSS_PREFIX"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-libdavs2
}

ffbuild_unconfigure() {
    echo --disable-libdavs2
}
