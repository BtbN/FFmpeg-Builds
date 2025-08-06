#!/bin/bash

SCRIPT_REPO="https://github.com/kcat/openal-soft.git"
SCRIPT_COMMIT="f15e855145be2a6f82a73bf5ba1d94456668011c"

ffbuild_enabled() {
    (( $(ffbuild_ffver) > 501 )) || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir cm_build && cd cm_build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DLIBTYPE=STATIC -DALSOFT_UTILS=OFF -DALSOFT_EXAMPLES=OFF  ..
    make -j$(nproc)
    make install

    echo "Libs.private: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/openal.pc

    if [[ $TARGET == win* ]]; then
        echo "Libs.private: -lole32 -luuid" >> "$FFBUILD_PREFIX"/lib/pkgconfig/openal.pc
    fi
}

ffbuild_configure() {
    echo --enable-openal
}

ffbuild_unconfigure() {
    echo --disable-openal
}
