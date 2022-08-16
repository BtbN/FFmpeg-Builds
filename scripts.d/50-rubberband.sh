#!/bin/bash

SCRIPT_REPO="https://github.com/breakfastquay/rubberband.git"
SCRIPT_COMMIT="e3ae576fcd0083f0b5c8cf5ecaa011a0bb46b35e"

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

    # Fix static linking
    echo "Requires.private: fftw3 samplerate" >> "$FFBUILD_PREFIX"/lib/pkgconfig/rubberband.pc
}

ffbuild_configure() {
    echo --enable-librubberband
}

ffbuild_unconfigure() {
    echo --disable-librubberband
}
