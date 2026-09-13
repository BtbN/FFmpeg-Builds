#!/bin/bash

SCRIPT_REPO="https://github.com/PCRE2Project/pcre2.git"
SCRIPT_COMMIT="aac57f978e38fb4a04899d623b68e0fbb5bcaf6c"

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
        --enable-pcre2-8
        --enable-unicode
        --disable-pcre2-16
        --disable-pcre2-32
        --disable-pcre2grep-libz
        --disable-pcre2grep-libbz2
        --disable-pcre2test-libedit
        --disable-pcre2test-libreadline
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
