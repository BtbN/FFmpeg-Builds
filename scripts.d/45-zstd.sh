#!/bin/bash

SCRIPT_REPO="https://github.com/facebook/zstd.git"
SCRIPT_COMMIT="49cf51799ea051457f57243527aa2058f999f005"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    # zstd touches C++ compiler if it is set in toolchain, even for a C-only build
    sed -i 's/LANGUAGES C /LANGUAGES C CXX /' build/cmake/CMakeLists.txt

    mkdir cmbuild && cd cmbuild

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DZSTD_BUILD_SHARED=OFF -DZSTD_BUILD_STATIC=ON -DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_TESTS=OFF -DZSTD_BUILD_CONTRIB=OFF \
        -DZSTD_LEGACY_SUPPORT=OFF ../build/cmake
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}
