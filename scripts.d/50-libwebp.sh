#!/bin/bash

SCRIPT_REPO="https://chromium.googlesource.com/webm/libwebp"
SCRIPT_COMMIT="9f14c2605b9c4d993f10ee5a8254f4645ec3ddef"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    run_autogen
    build_autotools \
        --enable-libwebpmux \
        --disable-libwebpextras \
        --disable-libwebpdemux \
        --disable-sdl \
        --disable-gl \
        --disable-png \
        --disable-jpeg \
        --disable-tiff \
        --disable-gif
}

ffbuild_configure() {
    echo $(ffbuild_enable libwebp)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libwebp)
}
