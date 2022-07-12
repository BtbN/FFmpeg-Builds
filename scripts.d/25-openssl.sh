#!/bin/bash

SCRIPT_REPO="https://github.com/openssl/openssl.git"
SCRIPT_COMMIT="OpenSSL_1_1_1q"
SCRIPT_TAGFILTER="OpenSSL_1_1_1*"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" openssl
    cd openssl

    local myconf=(
        threads
        zlib
        no-shared
        enable-camellia
        enable-ec
        enable-srp
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == win64 ]]; then
        myconf+=(
            --cross-compile-prefix="$FFBUILD_CROSS_PREFIX"
            mingw64
        )
    elif [[ $TARGET == win32 ]]; then
        myconf+=(
            --cross-compile-prefix="$FFBUILD_CROSS_PREFIX"
            mingw
        )
    elif [[ $TARGET == linux64 ]]; then
        myconf+=(
            --cross-compile-prefix="$FFBUILD_CROSS_PREFIX"
            linux-x86_64
        )
    elif [[ $TARGET == linuxarm64 ]]; then
        myconf+=(
            --cross-compile-prefix="$FFBUILD_CROSS_PREFIX"
            linux-aarch64
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./Configure "${myconf[@]}"

    sed -i -e "/^CFLAGS=/s|=.*|=${CFLAGS}|" -e "/^LDFLAGS=/s|=[[:space:]]*$|=${LDFLAGS}|" Makefile

    make -j$(nproc)
    make install_sw
}
