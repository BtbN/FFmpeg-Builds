#!/bin/bash

# https://breakfastquay.com/rubberband/
RUBBERBAND_SRC="https://breakfastquay.com/files/releases/rubberband-1.9.0.tar.bz2"

ffbuild_enabled() {
    [[ $VARIANT == gpl* ]] || return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    mkdir rubberband
    cd rubberband

    wget "$RUBBERBAND_SRC" -O rubberband.tar.gz || return -1
    tar xaf rubberband.tar.gz || return -1
    rm rubberband.tar.gz
    cd rubberband* || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --disable-ladspa
        --disable-vamp
        --disable-programs
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

    # Fix static linking
    echo "Requires.private: fftw3 samplerate" >> "$FFBUILD_PREFIX"/lib/pkgconfig/rubberband.pc

    cd ../..
    rm -rf rubberband
}

ffbuild_configure() {
    echo --enable-librubberband
}

ffbuild_unconfigure() {
    echo --disable-librubberband
}
