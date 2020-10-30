#!/bin/bash

# http://fftw.org/download.html
FFTW3_SRC="http://fftw.org/fftw-3.3.8.tar.gz"
FFTW3_SHA512="ab918b742a7c7dcb56390a0a0014f517a6dff9a2e4b4591060deeb2c652bf3c6868aa74559a422a276b853289b4b701bdcbd3d4d8c08943acf29167a7be81a38"

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
