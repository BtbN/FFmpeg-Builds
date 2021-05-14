#!/bin/bash

XVID_SRC="https://downloads.xvid.com/downloads/xvidcore-1.3.7.tar.gz"

ffbuild_enabled() {
    [[ $VARIANT == gpl* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir xvid
    cd xvid
    wget -O xvid.tar.gz "$XVID_SRC"
    tar xaf xvid.tar.gz
    rm xvid.tar.gz
    cd xvid*

    cd build/generic

    # The original code fails on a two-digit major...
    sed -i\
        -e 's/GCC_MAJOR=.*/GCC_MAJOR=10/' \
        -e 's/GCC_MINOR=.*/GCC_MINOR=0/' \
        configure.in

    ./bootstrap.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
    )

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

    if [[ $TARGET == win* ]]; then
        rm "$FFBUILD_PREFIX"/{bin/xvidcore.dll,lib/xvidcore.dll.a}
        mv "$FFBUILD_PREFIX"/lib/{,lib}xvidcore.a
    elif [[ $TARGET == linux* ]]; then
        rm "$FFBUILD_PREFIX"/lib/libxvidcore.so*
    fi
}

ffbuild_configure() {
    echo --enable-libxvid
}

ffbuild_unconfigure() {
    echo --disable-libxvid
}
