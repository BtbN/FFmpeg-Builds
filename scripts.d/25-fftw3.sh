#!/bin/bash

# https://fftw.org/download.html
FFTW3_SRC="https://fftw.org/fftw-3.3.10.tar.gz"
FFTW3_SHA512="2d34b5ccac7b08740dbdacc6ebe451d8a34cf9d9bfec85a5e776e87adf94abfd803c222412d8e10fbaa4ed46f504aa87180396af1b108666cde4314a55610b40"

ffbuild_enabled() {
    # Dependency of GPL-Only librubberband
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir fftw3
    cd fftw3

    check-wget fftw3.tar.gz "$FFTW3_SRC" "$FFTW3_SHA512"
    tar xaf fftw3.tar.gz
    rm fftw3.tar.gz
    cd fftw*

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --disable-fortran
        --disable-doc
        --with-our-malloc
        --enable-threads
        --with-combined-threads
        --with-incoming-stack-boundary=2
    )

    if [[ $TARGET != *arm64 ]]; then
        myconf+=(
            --enable-sse2
            --enable-avx
            --enable-avx2
        )
    fi

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}
