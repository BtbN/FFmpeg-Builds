#!/bin/bash

OPENSSL_SRC="https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-3.2.2.tar.gz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    mkdir openssl
    cd openssl
    wget "$OPENSSL_SRC" -O openssl.tar.gz || return -1
    tar xaf openssl.tar.gz || return -1
    rm openssl.tar.gz
    cd libressl* || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == win64 ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    elif [[ $TARGET == win32 ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}" || return -1

    sed -i -e "/^CFLAGS=/s|=.*|=${CFLAGS}|" -e "/^LDFLAGS=/s|=[[:space:]]*$|=${LDFLAGS}|" Makefile || return -1

    make -j$(nproc) || return -1
    make install || return -1

    cd ..
    rm -rf openssl
}
