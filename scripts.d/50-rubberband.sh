#!/bin/bash

SCRIPT_REPO="https://github.com/breakfastquay/rubberband.git"
SCRIPT_COMMIT="b317d0e81a8e0ea84269cc2c1dab2906ca8df271"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" rubberband
    cd rubberband

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        -Ddefault_library=static
        -Dfft=fftw
        -Dresampler=libsamplerate
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-librubberband
}

ffbuild_unconfigure() {
    echo --disable-librubberband
}
