#!/bin/bash

SCRIPT_REPO="https://github.com/FFTW/fftw3.git"
SCRIPT_COMMIT="7947c101a5b724fe8b9784218388b46d7e247132"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    sed -i 's/-libs nums/-use-ocamlfind -package num/' genfft/Makefile.am

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
