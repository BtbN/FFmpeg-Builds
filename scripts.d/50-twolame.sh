#!/bin/bash

SCRIPT_REPO="https://github.com/njh/twolame.git"
SCRIPT_COMMIT="3c7d49d95be71c26afdbaef14def92f3460c7373"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    # libtoolize version detection is broken, disable it, we got the right versions
    printf 'print "999999\\n"\n' > autogen-get-version-mock.pl
    sed -i -e 's|/autogen-get-version.pl|/autogen-get-version-mock.pl|g' ./autogen.sh

    NOCONFIGURE=1 ./autogen.sh
    touch doc/twolame.1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --with-pic
        --disable-shared
        --enable-static
        --disable-sndfile
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

    sed -i 's/Cflags:/Cflags: -DLIBTWOLAME_STATIC/' "$FFBUILD_DESTPREFIX"/lib/pkgconfig/twolame.pc
}

ffbuild_configure() {
    echo --enable-libtwolame
}

ffbuild_unconfigure() {
    echo --disable-libtwolame
}

ffbuild_cflags() {
    echo -DLIBTWOLAME_STATIC
}
