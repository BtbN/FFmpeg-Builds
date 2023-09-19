#!/bin/bash

SCRIPT_REPO="https://gitlab.com/AOMediaCodec/SVT-AV1.git"
SCRIPT_COMMIT="a6f0981c2b82aea05205b96bfebb1e6cd53790de"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerdl() {
    to_df "RUN git clone \"$SCRIPT_REPO\" \"$SELF\" && git -C \"$SELF\" checkout \"$SCRIPT_COMMIT\""
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR/$SELF"

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF -DBUILD_APPS=OFF -DENABLE_AVX512=ON ..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libsvtav1
}

ffbuild_unconfigure() {
    echo --disable-libsvtav1
}
