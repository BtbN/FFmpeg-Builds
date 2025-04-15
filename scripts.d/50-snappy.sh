#!/bin/bash

SCRIPT_REPO="https://github.com/google/snappy.git"
SCRIPT_COMMIT="6af9287fbdb913f0794d0148c6aa43b58e63c8e3"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF -DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF -DSNAPPY_FUZZING_BUILD=OFF \
        -DSNAPPY_REQUIRE_AVX=OFF -DSNAPPY_REQUIRE_AVX2=OFF ..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libsnappy
}

ffbuild_unconfigure() {
    echo --disable-libsnappy
}
