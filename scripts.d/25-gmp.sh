#!/bin/bash

GMP_SRC="https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir gmp
    cd gmp

    wget "$GMP_SRC" -O gmp.tar.xz
    tar xaf gmp.tar.xz
    rm gmp.tar.xz
    cd gmp*

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
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
}

ffbuild_configure() {
    echo --enable-gmp
}

ffbuild_unconfigure() {
    echo --disable-gmp
}
