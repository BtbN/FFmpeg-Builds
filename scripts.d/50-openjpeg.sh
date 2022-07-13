#!/bin/bash

SCRIPT_REPO="https://github.com/uclouvain/openjpeg.git"
SCRIPT_COMMIT="e3f07dcc07c651321ec3b5f540ef698bbe6f1906"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" openjpeg
    cd openjpeg

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=OFF -DBUILD_PKGCONFIG_FILES=ON -DBUILD_CODEC=OFF -DWITH_ASTYLE=OFF -DBUILD_TESTING=OFF ..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libopenjpeg
}

ffbuild_unconfigure() {
    echo --disable-libopenjpeg
}
