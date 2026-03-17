#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/vorbis.git"
SCRIPT_COMMIT="8de7001691d9177e30ff16a98b37b1e6fd15f7af"

ffbuild_depends() {
    echo base
    echo libogg
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --disable-oggtest
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
    echo --enable-libvorbis
}

ffbuild_unconfigure() {
    echo --disable-libvorbis
}
