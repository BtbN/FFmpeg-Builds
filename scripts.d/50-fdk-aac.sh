#!/bin/bash

SCRIPT_REPO="https://github.com/mstorsjo/fdk-aac.git"
SCRIPT_COMMIT="c41c3c7516ea8d0d78a53b96b30bed3a29745cc6"

ffbuild_enabled() {
    [[ $VARIANT == nonfree* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --disable-example
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
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-libfdk-aac
}

ffbuild_unconfigure() {
    echo --disable-libfdk-aac
}
