#!/bin/bash

MINGW_REPO="https://github.com/mirror/mingw-w64.git"
MINGW_COMMIT="c17efd05d019136a9b3527e2dd32234175c0a9f9"

ffbuild_enabled() {
    [[ $TARGET == win* ]] || return -1
    return 0
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
        --with-default-win32-winnt="0x601"
        --enable-idl
    )

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    cd ../mingw-w64-libraries/winpthreads

    autoreconf -i

    local myconf=(
        --prefix="/usr/$FFBUILD_TOOLCHAIN"
        --host="$FFBUILD_TOOLCHAIN"
        --with-pic
        --disable-shared
        --enable-static
    )

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --disable-w32threads --enable-pthreads
}
