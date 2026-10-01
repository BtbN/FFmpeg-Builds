#!/bin/bash

SCRIPT_REPO="https://github.com/Cyan4973/xxHash.git"
SCRIPT_COMMIT="680bf463fa1ca0461b9a7c2dab7556e1f54cf4cf"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir cmbuild && cd cmbuild

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_SHARED_LIBS=OFF -DXXHASH_BUILD_XXHSUM=OFF ../build/cmake
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}
