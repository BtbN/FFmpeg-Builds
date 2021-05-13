#!/bin/bash

# https://breakfastquay.com/rubberband/
RUBBERBAND_SRC="https://breakfastquay.com/files/releases/rubberband-1.9.1.tar.bz2"

ffbuild_enabled() {
    [[ $VARIANT == gpl* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir rubberband
    cd rubberband

    wget "$RUBBERBAND_SRC" -O rubberband.tar.gz
    tar xaf rubberband.tar.gz
    rm rubberband.tar.gz
    cd rubberband*

    # Fix broken cross compilation
    sed -i 's/build_machine.system/host_machine.system/' meson.build

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        -Dno_shared=true
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    elif [[ $TARGET != linux* ]]; then
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
