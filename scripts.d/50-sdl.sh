#!/bin/bash

SDL_REPO="https://github.com/libsdl-org/SDL.git"
SDL_COMMIT="615f7b4453864d9475e8b20faa78ec67be357f1e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SDL_REPO" "$SDL_COMMIT" sdl
    cd sdl

    mkdir build && cd build

    local mycmake=(
        -DSDL_SHARED=OFF
        -DSDL_STATIC=ON
        -DSDL_STATIC_PIC=ON
    )

    if [[ $TARGET == linux* ]]; then
        mycmake+=(
            -DSDL_X11_SHARED=OFF
            -DHAVE_XGENERICEVENT=TRUE
            -DSDL_VIDEO_DRIVER_X11_HAS_XKBKEYCODETOKEYSYM=1
        )
    fi

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" "${mycmake[@]}" ..

    ninja -j$(nproc)
    ninja install

    if [[ $TARGET == linux* ]]; then
        sed -ri -e 's/ \-l\/.+?\.a//g' \
            "$FFBUILD_PREFIX"/lib/pkgconfig/sdl2.pc
        echo 'Requires: xxf86vm xscrnsaver xrandr xfixes xi xinerama xcursor' >> "$FFBUILD_PREFIX"/lib/pkgconfig/sdl2.pc
    elif [[ $TARGET == win* ]]; then
        sed -ri -e 's/\-Wl,\-\-no\-undefined.*//' \
            -e 's/ \-mwindows//g' \
            -e 's/ \-lSDL2main//g' \
            -e 's/ \-Dmain=SDL_main//g' \
            "$FFBUILD_PREFIX"/lib/pkgconfig/sdl2.pc
    fi
}

ffbuild_configure() {
    echo --enable-sdl2
}

ffbuild_unconfigure() {
    echo --disable-sdl2
}
