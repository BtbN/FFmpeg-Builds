#!/bin/bash

SCRIPT_REPO="https://github.com/openssl/openssl.git"
SCRIPT_COMMIT="openssl-3.2.3"
SCRIPT_TAGFILTER="openssl-3.2.*"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo "git submodule update --init --recursive --depth=1"
}

ffbuild_dockerbuild() {
    local myconf=(
        threads
        zlib
        no-shared
        no-tests
        no-apps
        no-legacy
        no-ssl2
        no-ssl3
        enable-camellia
        enable-ec
        enable-srp
        --prefix="$FFBUILD_PREFIX"
        --libdir=lib
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
    elif [[ $TARGET == winarm64 ]]; then
        myconf+=(
            --cross-compile-prefix="$FFBUILD_CROSS_PREFIX"
            mingwarm64
        )

        cat <<EOF >Configurations/50-win-arm-mingw.conf
my %targets = (
    "mingwarm64" => {
        inherit_from     => [ "mingw-common" ],
        cflags           => "",
        sys_id           => "MINGWARM64",
        bn_ops           => add("SIXTY_FOUR_BIT"),
        asm_arch         => 'aarch64',
        uplink_arch      => 'armv8',
        perlasm_scheme   => "win64",
        shared_rcflag    => "",
        multilib         => "-arm64",
    },
);
EOF
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

    export CFLAGS="$CFLAGS -fno-strict-aliasing"
    export CXXFLAGS="$CXXFLAGS -fno-strict-aliasing"

    # OpenSSL build system prepends the cross prefix itself
    export CC="${CC/${FFBUILD_CROSS_PREFIX}/}"
    export CXX="${CXX/${FFBUILD_CROSS_PREFIX}/}"
    export AR="${AR/${FFBUILD_CROSS_PREFIX}/}"
    export RANLIB="${RANLIB/${FFBUILD_CROSS_PREFIX}/}"

    ./Configure "${myconf[@]}"

    sed -i -e "/^CFLAGS=/s|=.*|=${CFLAGS}|" -e "/^LDFLAGS=/s|=[[:space:]]*$|=${LDFLAGS}|" Makefile

    make -j$(nproc) build_sw
    make install_sw
}

ffbuild_configure() {
    [[ $TARGET == win* ]] && return 0
    echo --enable-openssl
}
