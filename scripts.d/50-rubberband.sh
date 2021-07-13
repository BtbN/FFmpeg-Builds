#!/bin/bash

# https://breakfastquay.com/rubberband/
RUBBERBAND_SRC="https://breakfastquay.com/files/releases/rubberband-1.9.2.tar.bz2"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir rubberband
    cd rubberband

    wget "$RUBBERBAND_SRC" -O rubberband.tar.gz
    tar xaf rubberband.tar.gz
    rm rubberband.tar.gz
    cd rubberband*

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        -Dno_shared=true
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
