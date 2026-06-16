#!/bin/bash

SCRIPT_REPO="https://github.com/curl/curl.git"
SCRIPT_COMMIT="7806fb36c530027d7367e22e9299d0dde6ae5bb0"

ffbuild_depends() {
    echo base
    echo zlib
    [[ $TARGET != win* ]] && echo openssl
}

ffbuild_enabled() {
    (( $(ffbuild_ffver) <= 801 )) && return -1
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

        -DHTTP_ONLY=ON
    )

    if [[ $TARGET == win* ]]; then
        mycmake+=(
            -DCURL_USE_SCHANNEL=ON
            -DCURL_USE_OPENSSL=OFF
        )
    else
        mycmake+=(
            -DCURL_USE_OPENSSL=ON
        )
    fi

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON "${mycmake[@]}" ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    cat "$FFBUILD_DESTPREFIX"/lib/pkgconfig/libcurl.pc
}
