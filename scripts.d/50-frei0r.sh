#!/bin/bash

SCRIPT_REPO="https://github.com/dyne/frei0r.git"
SCRIPT_COMMIT="8b11714bd7cb9d7453e6cf4d4b0066868ed504cf"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    (( $(ffbuild_ffver) >= 500 )) || return -1
    return 0
}

ffbuild_dockerfinal() {
    to_df "COPY --link --from=${PREVLAYER} \$FFBUILD_PREFIX/. \$FFBUILD_PREFIX"
    to_df "ENV FREI0R_PATH=\$FFBUILD_PREFIX/lib/frei0r-1"
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DWITHOUT_OPENCV=ON -DWITHOUT_FACERECOGNITION=ON -DWITHOUT_CAIRO=ON -DWITHOUT_GAVL=ON ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}

ffbuild_configure() {
    echo --enable-frei0r
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) >= 404 )) || return 0
    echo --disable-frei0r
}
