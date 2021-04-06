#!/bin/bash

SDL_SRC="https://libsdl.org/release/SDL2-2.0.14.tar.gz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir sdl
    cd sdl

    wget "$SDL_SRC" -O SDL.tar.gz
    tar xaf SDL.tar.gz
    rm SDL.tar.gz
    cd SDL*

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
    )

    if [[ $TARGET == win* ]]; then
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
    echo --enable-sdl2
}

ffbuild_unconfigure() {
    echo --disable-sdl2
}

ffbuild_cflags() {
    return 0
}

ffbuild_ldflags() {
    return 0
}
