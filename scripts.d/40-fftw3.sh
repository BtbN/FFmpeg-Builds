#!/bin/bash

# http://fftw.org/download.html
FFTW3_SRC="http://fftw.org/fftw-3.3.9.tar.gz"
FFTW3_SHA512="52ebc2a33063a41fd478f6ea2acbf3b511867f736591d273dd57f9dfca5d3e0b0c73157921b3a36f1a7cfd741a8a6bde0fd80de578040ae730ea168b5ba466cf"

ffbuild_enabled() {
    # Dependency of GPL-Only librubberband
    [[ $VARIANT == gpl* ]] || return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
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
        --disable-doc
        --with-our-malloc
        --enable-threads
        --with-combined-threads
        --with-incoming-stack-boundary=2
        --enable-sse2
        --enable-avx
        --enable-avx2
    )

    if [[ $TARGET == win* ]]; then
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

    cd ../..
    rm -rf fftw3
}
