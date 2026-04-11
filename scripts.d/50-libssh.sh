#!/bin/bash

SCRIPT_REPO="https://gitlab.com/libssh/libssh-mirror.git"
SCRIPT_COMMIT="c853d86bb574420a2f24f99c7a400de25f122346"

ffbuild_depends() {
    echo base
    echo zlib
    echo openssl
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    export CFLAGS="$CFLAGS -Dmd5=libssh_md5"

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DHAVE_STRNDUP=YES -DBUILD_SHARED_LIBS=OFF -DWITH_EXAMPLES=OFF -DWITH_SERVER=OFF -DWITH_SFTP=ON -DWITH_ZLIB=ON \
        ..

    # Fix compilation on windows, mingw exports the symbol, but the header only shows it for c23.
    # Since the cmake script only checks for the symbol, it succeeds. But then fails to build.
    echo '#include <stddef.h>' >> config.h
    echo 'char * strndup(const char *s, size_t c);' >> config.h

    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    {
        echo "Requires.private: libssl libcrypto zlib"
        echo "Cflags.private: -DLIBSSH_STATIC"
        if [[ $TARGET == win* ]]; then
            echo "Libs.private: -liphlpapi -lws2_32"
        fi
        echo "Libs.private: -lpthread"
    } >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/libssh.pc
}

ffbuild_configure() {
    echo --enable-libssh
}

ffbuild_unconfigure() {
    echo --disable-libssh
}
