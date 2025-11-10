#!/bin/bash

SCRIPT_REPO="https://github.com/FFTW/fftw3.git"
SCRIPT_COMMIT="adde9bec41206a3d6bbb02bdbf9f64726d7d2009"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    sed -i 's/-libs unix,nums/-use-ocamlfind -package unix,num/' genfft/Makefile.am
    sed -i 's/windows.h/process.h/' configure.ac

    local extra_opts=(
        --enable-maintainer-mode
        --disable-fortran
        --disable-doc
        --with-our-malloc
        --enable-threads
        --with-combined-threads
        --with-incoming-stack-boundary=2
    )

    if [[ $TARGET != *arm64 ]]; then
        extra_opts+=(
            --enable-sse2
            --enable-avx
            --enable-avx2
        )
    fi

    ./bootstrap.sh "${extra_opts[@]}"
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}
