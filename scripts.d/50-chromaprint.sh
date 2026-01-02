#!/bin/bash

SCRIPT_REPO="https://github.com/acoustid/chromaprint.git"
SCRIPT_COMMIT="9b6a0c61ecbeab75271bab4aca651d8dff41c5d6"

ffbuild_depends() {
    echo base
    echo fftw3
}

ffbuild_enabled() {
    (( $(ffbuild_ffver) >= 600 )) || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=OFF -DBUILD_TOOLS=OFF -DBUILD_TESTS=OFF -DFFT_LIB=fftw3 ..
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"

    echo "Libs.private: -lfftw3 -lstdc++" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/libchromaprint.pc
    echo "Cflags.private: -DCHROMAPRINT_NODLL" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/libchromaprint.pc
}

ffbuild_configure() {
    echo --enable-chromaprint
}

ffbuild_unconfigure() {
    echo --disable-chromaprint
}
