#!/bin/bash

SVTAV1_REPO="https://gitlab.com/AOMediaCodec/SVT-AV1.git"
SVTAV1_COMMIT="a9dcf001750ce894187c4bed216675ccc5e038e9"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return -1
}

ffbuild_dockerbuild() {
    git clone "$SVTAV1_REPO" svtav1
    cd svtav1
    git checkout "$SVTAV1_COMMIT"

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF -DBUILD_APPS=OFF ..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libsvtav1
}

ffbuild_unconfigure() {
    echo --disable-libsvtav1
}
