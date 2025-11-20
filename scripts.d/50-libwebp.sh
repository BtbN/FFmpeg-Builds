#!/bin/bash

SCRIPT_REPO="https://chromium.googlesource.com/webm/libwebp"
SCRIPT_COMMIT="2760d8782718256ce0157ee7fac841ed1c69bdc8"

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
