#!/bin/bash

LIBVPX_REPO="https://chromium.googlesource.com/webm/libvpx"
LIBVPX_COMMIT="3b21aeac8b7d5a52b6360d878cb4df593e87113e"

ffbuild_enabled() {
    return -1
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBVPX_REPO" "$LIBVPX_COMMIT" libvpx
    cd libvpx

    local myconf=(
        --disable-shared
        --enable-static
        --enable-pic
        --disable-examples
        --disable-tools
        --disable-docs
        --enable-vp9-highbitdepth
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == win64 ]]; then
        myconf+=(
            --target=x86_64-win64-gcc
        )
        export CROSS="$FFBUILD_CROSS_PREFIX"
    elif [[ $TARGET == win32 ]]; then
        myconf+=(
            --target=x86-win32-gcc
        )
        export CROSS="$FFBUILD_CROSS_PREFIX"
    elif [[ $TARGET == linux* ]]; then
        myconf+=(
            --target=x86_64-linux-gcc
        )
        export CROSS="$FFBUILD_CROSS_PREFIX"
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libvpx
}

ffbuild_unconfigure() {
    echo --disable-libvpx
}
