#!/bin/bash

SCRIPT_REPO="https://git.libssh.org/projects/libssh.git"
SCRIPT_COMMIT="ac6d2fad4a8bf07277127736367e90387646363f"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" libssh
    cd libssh

    mkdir build && cd build

    if [[ $TARGET == win* ]]; then
        export CFLAGS="$CFLAGS -Dgettimeofday=ssh_gettimeofday"
        export CXXFLAGS="$CFLAGS -Dgettimeofday=ssh_gettimeofday"
    fi

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DWITH_EXAMPLES=OFF -DWITH_SERVER=OFF \
        -DWITH_SFTP=ON -DWITH_ZLIB=ON ..

    ninja -j$(nproc)
    ninja install

    {
        echo "Requires.private: libssl libcrypto zlib"
        echo "Cflags.private: -DLIBSSH_STATIC"
    } >> "$FFBUILD_PREFIX"/lib/pkgconfig/libssh.pc
}

ffbuild_configure() {
    echo --enable-libssh
}

ffbuild_unconfigure() {
    echo --disable-libssh
}
