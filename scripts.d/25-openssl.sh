#!/bin/bash

OPENSSL_REPO="https://github.com/openssl/openssl.git"
OPENSSL_COMMIT="OpenSSL_1_1_1g"

ffbuild_enabled() {
    return -1
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git clone "$OPENSSL_REPO" openssl || return -1
    cd openssl
    git checkout "$OPENSSL_COMMIT" || return -1

    local myconf=(
        threads
        zlib
        no-shared
        enable-camellia
        enable-ec
        enable-srp
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-compile-prefix="$FFBUILD_CROSS_PREFIX"
            mingw64
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./Configure "${myconf[@]}" || return -1

    sed -i -e "/^CFLAGS=/s|=.*|=${CFLAGS} -O2|" -e "/^LDFLAGS=/s|=[[:space:]]*$|=${LDFLAGS}|" Makefile || return -1

    make -j$(nproc) || return -1
    make install_sw || return -1

    cd ..
    rm -rf openssl
}

ffbuild_configure() {
    echo --enable-openssl
}

ffbuild_unconfigure() {
    echo --disable-openssl
}
