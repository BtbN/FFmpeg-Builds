#!/bin/bash

SDL_REPO="https://github.com/libsdl-org/SDL.git"
SDL_COMMIT="981e1e3c4489add5bf6d4df5415af3cf1ef2773d"

ffbuild_enabled() {
    [[ $TARGET == linuxarm64 ]] && return -1
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
        -DSDL_TEST=OFF
    )

    if [[ $TARGET == linux* ]]; then
        mycmake+=(
            -DSDL_X11=ON
            -DSDL_X11_SHARED=OFF
            -DHAVE_XGENERICEVENT=TRUE
            -DSDL_VIDEO_DRIVER_X11_HAS_XKBKEYCODETOKEYSYM=1

            -DSDL_PULSEAUDIO=ON
            -DSDL_PULSEAUDIO_SHARED=OFF
        )
    fi

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" "${mycmake[@]}" ..

    ninja -j$(nproc)
    ninja install

    if [[ $TARGET == linux* ]]; then
        sed -ri -e 's/\-Wl,\-\-no\-undefined.*//' \
            -e 's/ \-l\/.+?\.a//g' \
            "$FFBUILD_PREFIX"/lib/pkgconfig/sdl2.pc
        echo 'Requires: libpulse-simple xxf86vm xscrnsaver xrandr xfixes xi xinerama xcursor' >> "$FFBUILD_PREFIX"/lib/pkgconfig/sdl2.pc
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
