#!/bin/bash

SDL_SRC="https://libsdl.org/release/SDL2-2.0.12.tar.gz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    mkdir sdl
    cd sdl

    wget "$SDL_SRC" -O SDL.tar.gz || return -1
    tar xaf SDL.tar.gz || return -1
    rm SDL.tar.gz
    cd SDL* || return -1

    ./autogen.sh || return -1

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

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ../..
    rm -rf sdl
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
