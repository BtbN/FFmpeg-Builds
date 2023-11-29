#!/bin/bash

SCRIPT_REPO="https://github.com/Haivision/srt.git"
SCRIPT_COMMIT="4a8067cf38656926494ae6b150cf7d148213c024"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR/$SELF"

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DENABLE_CXX_DEPS=ON -DUSE_STATIC_LIBSTDCXX=ON -DENABLE_ENCRYPTION=ON -DENABLE_APPS=OFF ..
    make -j$(nproc)
    make install

    echo "Libs.private: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/srt.pc
}

ffbuild_configure() {
    echo --enable-libsrt
}

ffbuild_unconfigure() {
    echo --disable-libsrt
}
