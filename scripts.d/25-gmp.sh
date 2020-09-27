#!/bin/bash

GMP_SRC="https://ftp.gnu.org/gnu/gmp/gmp-6.2.0.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    mkdir gmp
    cd gmp

    wget "$GMP_SRC" -O gmp.tar.xz || return -1
    tar xaf gmp.tar.xz || return -1
    rm gmp.tar.xz
    cd gmp* || return -1

    autoreconf -i || return -1

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

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ../..
    rm -rf gmp
}

ffbuild_configure() {
    echo --enable-gmp
}

ffbuild_unconfigure() {
    echo --disable-gmp
}
