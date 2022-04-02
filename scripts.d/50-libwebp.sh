#!/bin/bash

WEBP_REPO="https://chromium.googlesource.com/webm/libwebp"
WEBP_COMMIT="0fa0ea5488ab37f229b42c363c73c4bae3d90386"

ffbuild_enabled() {
    return -1
}

ffbuild_dockerbuild() {
    git-mini-clone "$WEBP_REPO" "$WEBP_COMMIT" webp
    cd webp

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --enable-libwebpmux
        --disable-libwebpextras
        --disable-libwebpdemux
        --disable-sdl
        --disable-gl
        --disable-png
        --disable-jpeg
        --disable-tiff
        --disable-gif
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
    echo --enable-libwebp
}

ffbuild_unconfigure() {
    echo --disable-libwebp
}
