#!/bin/bash

SCRIPT_REPO="https://git.code.sf.net/p/mingw-w64/mingw-w64.git"
SCRIPT_COMMIT="3638d5e9a6f28354bc3e18f04ba0d97e2cc3b44c"

ffbuild_enabled() {
    [[ $TARGET == win* ]] || return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --from=${SELFLAYER} /opt/mingw/. /"
    to_df "COPY --from=${SELFLAYER} /opt/mingw/. /opt/mingw"
}

ffbuild_dockerfinal() {
    to_df "COPY --from=${PREVLAYER} /opt/mingw/. /"
}

ffbuild_dockerdl() {
    to_df "RUN retry-tool sh -c \"rm -rf mingw && git clone '$SCRIPT_REPO' mingw\" && cd mingw && git checkout \"$SCRIPT_COMMIT\""
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR/mingw"

    cd mingw-w64-headers

    unset CFLAGS
    unset CXXFLAGS
    unset LDFLAGS
    unset PKG_CONFIG_LIBDIR

    GCC_SYSROOT="$(${FFBUILD_CROSS_PREFIX}gcc -print-sysroot)"

    local myconf=(
        --prefix="$GCC_SYSROOT/usr/$FFBUILD_TOOLCHAIN"
        --host="$FFBUILD_TOOLCHAIN"
        --with-default-win32-winnt="0x601"
        --with-default-msvcrt=ucrt
        --enable-idl
    )

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="/opt/mingw"

    cd ../mingw-w64-libraries/winpthreads

    local myconf=(
        --prefix="$GCC_SYSROOT/usr/$FFBUILD_TOOLCHAIN"
        --host="$FFBUILD_TOOLCHAIN"
        --with-pic
        --disable-shared
        --enable-static
    )

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="/opt/mingw"
}

ffbuild_configure() {
    echo --disable-w32threads --enable-pthreads
}
