#!/bin/bash

SCRIPT_REPO="https://github.com/pkuvcl/davs2.git"
SCRIPT_COMMIT="b06d7585620f4e90a6d19a2926bb4e59793b8942"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $TARGET == win32 ]] && return -1
    # davs2 aarch64 support is broken
    [[ $TARGET == linuxarm64 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git clone "$SCRIPT_REPO" davs2
    cd davs2
    git checkout "$SCRIPT_COMMIT"
    cd build/linux

    local myconf=(
        --disable-cli
        --enable-pic
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
    make install
}

ffbuild_configure() {
    echo --enable-libdavs2
}

ffbuild_unconfigure() {
    echo --disable-libdavs2
}
