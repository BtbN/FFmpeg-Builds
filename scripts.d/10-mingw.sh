#!/bin/bash

MINGW_REPO="https://github.com/mirror/mingw-w64.git"
MINGW_COMMIT="f14b748bb7e95ced6d6f0cf73139da420bc2832f"

ffbuild_enabled() {
    [[ $TARGET == win* ]] || return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$MINGW_REPO" "$MINGW_COMMIT" mingw
    cd mingw/mingw-w64-headers

    unset CFLAGS
    unset CXXFLAGS
    unset LDFLAGS
    unset PKG_CONFIG_LIBDIR

    autoreconf -i

    local myconf=(
        --prefix="/usr/$FFBUILD_TOOLCHAIN"
        --host="$FFBUILD_TOOLCHAIN"
        --enable-idl
    )

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ../mingw-w64-libraries/winpthreads

    autoreconf -i

    local myconf=(
        --prefix="/usr/$FFBUILD_TOOLCHAIN"
        --host="$FFBUILD_TOOLCHAIN"
        --with-pic
        --disable-shared
        --enable-static
    )

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ../../..
    rm -rf mingw
}
