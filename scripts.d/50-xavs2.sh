#!/bin/bash

SCRIPT_REPO="https://github.com/pkuvcl/xavs2.git"
SCRIPT_COMMIT="eae1e8b9d12468059bdd7dee893508e470fa83d8"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $TARGET == win32 ]] && return -1
    # xavs2 aarch64 support is broken
    [[ $TARGET == linuxarm64 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git clone "$SCRIPT_REPO" xavs2
    cd xavs2
    git checkout "$SCRIPT_COMMIT"
    cd build/linux

    local myconf=(
        --disable-cli
        --enable-static
        --enable-pic
        --disable-avs
        --disable-swscale
        --disable-lavf
        --disable-ffms
        --disable-gpac
        --disable-lsmash
        --extra-asflags="-w-macro-params-legacy"
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
    echo --enable-libxavs2
}

ffbuild_unconfigure() {
    echo --disable-libxavs2
}
