#!/bin/bash

FDK_REPO="https://github.com/mstorsjo/fdk-aac.git"
FDK_COMMIT="072f2cdafdd2bb7ed2d630d09c2a5697a4aec53d"

ffbuild_enabled() {
    [[ $VARIANT == nonfree* ]] || return -1
    return -1
}

ffbuild_dockerbuild() {
    git-mini-clone "$FDK_REPO" "$FDK_COMMIT" fdk
    cd fdk

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
    make install
}

ffbuild_configure() {
    echo --enable-libfdk-aac
}

ffbuild_unconfigure() {
    echo --disable-libfdk-aac
}
