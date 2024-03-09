#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/libdvdcss.git"
SCRIPT_COMMIT="d0b6a291c24eda3727ad5c7a14956fc1fc82446d"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $ADDINS_STR == *4.4* ]] && return -1
    [[ $ADDINS_STR == *5.0* ]] && return -1
    [[ $ADDINS_STR == *5.1* ]] && return -1
    [[ $ADDINS_STR == *6.0* ]] && return -1
    [[ $ADDINS_STR == *6.1* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --disable-doc
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$CFLAGS -Dprint_error=dvdcss_print_error -Dprint_debug=dvdcss_print_debug"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}
