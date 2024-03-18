#!/bin/bash

SCRIPT_REPO="https://github.com/libsdl-org/SDL.git"
SCRIPT_COMMIT="c17d2246fb0ed2fa5b16acbf1f2b3aa7e5ddd3cf"
SCRIPT_BRANCH="SDL2"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
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

    sed -ri -e 's/ -lSDL2//g' \
        -e 's/Libs: /Libs: -lSDL2 /'\
        "$FFBUILD_PREFIX"/lib/pkgconfig/sdl2.pc

    echo 'Requires: samplerate' >> "$FFBUILD_PREFIX"/lib/pkgconfig/sdl2.pc
}

ffbuild_configure() {
    echo --enable-sdl2
}

ffbuild_unconfigure() {
    echo --disable-sdl2
}
