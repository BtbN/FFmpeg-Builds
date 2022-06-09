#!/bin/bash

RUBBERBAND_REPO="https://github.com/breakfastquay/rubberband.git"
RUBBERBAND_COMMIT="4cff1741664918791474da9a9d41f48cc3119229"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$RUBBERBAND_REPO" "$RUBBERBAND_COMMIT" rubberband
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
