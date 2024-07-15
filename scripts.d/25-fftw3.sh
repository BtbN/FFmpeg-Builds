#!/bin/bash

SCRIPT_REPO="https://github.com/FFTW/fftw3.git"
SCRIPT_COMMIT="187045ea647ba19c55db5f503d11bd811ee6b56e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-maintainer-mode
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

    sed -i 's/windows.h/process.h/' configure.ac

    ./bootstrap.sh "${myconf[@]}"
    make -j$(nproc)
    make install
}
