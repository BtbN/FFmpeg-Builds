#!/bin/bash

SCRIPT_REPO="https://github.com/curl/curl.git"
SCRIPT_COMMIT="4c67658f953751de9e66bb5f9729af821a641341"

ffbuild_depends() {
    echo base
    echo zlib
    [[ $TARGET != win* ]] && echo openssl
}

ffbuild_enabled() {
    (( $(ffbuild_ffver) <= 900 )) && return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local mycmake=(
        -DBUILD_CURL_EXE=OFF
        -DBUILD_LIBCURL_DOCS=OFF
        -DBUILD_MISC_DOCS=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_CURL_MANUAL=OFF

        -DENABLE_ARES=OFF
        -DENABLE_THREADED_RESOLVER=ON

        -DCURL_ZLIB=ON
        # -DCURL_BROTLI=ON
        # -DCURL_ZSTD=ON
        -DCURL_USE_LIBPSL=OFF
        -DCURL_USE_LIBSSH2=OFF

        -DCURL_DISABLE_DICT=ON
        -DCURL_DISABLE_FILE=ON
        -DCURL_DISABLE_GOPHER=ON
        -DCURL_DISABLE_IMAP=ON
        -DCURL_DISABLE_IPFS=ON
        -DCURL_DISABLE_LDAP=ON
        -DCURL_DISABLE_LDAPS=ON
        -DCURL_DISABLE_MQTT=ON
        -DCURL_DISABLE_POP3=ON
        -DCURL_DISABLE_RTSP=ON
        -DCURL_DISABLE_SMTP=ON
        -DCURL_DISABLE_TELNET=ON
        -DCURL_DISABLE_TFTP=ON
        -DCURL_DISABLE_WEBSOCKETS=ON
    )

    if [[ $TARGET == win* ]]; then
        mycmake+=(
            -DCURL_USE_SCHANNEL=ON
            -DCURL_USE_OPENSSL=OFF
        )
    else
        mycmake+=(
            -DCURL_USE_OPENSSL=ON
            -DOPENSSL_USE_STATIC_LIBS=ON
            -DCURL_CA_FALLBACK=ON
        )
    fi

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON "${mycmake[@]}" ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    cat "$FFBUILD_DESTPREFIX"/lib/pkgconfig/libcurl.pc
}

ffbuild_configure() {
    echo --enable-libcurl
}
