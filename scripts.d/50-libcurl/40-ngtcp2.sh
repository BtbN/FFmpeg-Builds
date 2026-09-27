#!/bin/bash

SCRIPT_REPO="https://github.com/ngtcp2/ngtcp2.git"
SCRIPT_COMMIT="a4925d70647b75286b28c37be260de3729c2de3d"

ffbuild_depends() {
    echo base
    echo openssl
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    # The check for the QUIC API of OpenSSL links a test program. That fails, as
    # cmake leaves out what our static OpenSSL depends on, zlib for one.
    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DENABLE_SHARED_LIB=OFF -DENABLE_STATIC_LIB=ON -DENABLE_LIB_ONLY=ON -DBUILD_TESTING=OFF \
        -DENABLE_OPENSSL=ON -DHAVE_SSL_SET_QUIC_TLS_CBS=ON ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    echo "Cflags.private: -DNGTCP2_STATICLIB" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/libngtcp2.pc
}
