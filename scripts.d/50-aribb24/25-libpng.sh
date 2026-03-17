#!/bin/bash

SCRIPT_REPO="https://github.com/glennrp/libpng.git"
SCRIPT_COMMIT="28cb99fe65f09e79703ac2c3008649e14c7b0844"

ffbuild_depends() {
    echo base
    echo zlib
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
        --with-pic
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CPPFLAGS="$CPPFLAGS -I$FFBUILD_PREFIX/include"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}
