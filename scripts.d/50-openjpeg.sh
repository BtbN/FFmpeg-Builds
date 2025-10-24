#!/bin/bash

SCRIPT_REPO="https://github.com/uclouvain/openjpeg.git"
SCRIPT_COMMIT="1ad9bec2c12ee445ce23e660f5e4fe870b9d5e09"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=OFF -DBUILD_PKGCONFIG_FILES=ON -DBUILD_CODEC=OFF -DWITH_ASTYLE=OFF -DBUILD_TESTING=OFF ..
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-libopenjpeg
}

ffbuild_unconfigure() {
    echo --disable-libopenjpeg
}
