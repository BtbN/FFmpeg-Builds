#!/bin/bash

SCRIPT_REPO="https://gitlab.com/libssh/libssh-mirror.git"
SCRIPT_COMMIT="63fbf00efef84f1591c3c82911c6a92e77ca8d2c"

ffbuild_depends() {
    echo base
    echo zlib
    echo openssl
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    build_cmake -GNinja \
        -DWITH_EXAMPLES=OFF \
        -DWITH_SERVER=OFF \
        -DWITH_SFTP=ON \
        -DWITH_ZLIB=ON

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
    echo $(ffbuild_enable libssh)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libssh)
}
