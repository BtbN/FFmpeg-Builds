#!/bin/bash

SCRIPT_REPO="https://github.com/google/snappy.git"
SCRIPT_COMMIT="9c28114a38866f6deeaa826db918293bc28ae410"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local mycmake=()
    if [[ $TARGET == linuxriscv64 ]]; then
        # rv64gc does not include vectors; optimized-away probes can misdetect RVV.
        mycmake+=( -DSNAPPY_RVV_1=OFF -DSNAPPY_RVV_0_7=OFF )
    fi

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF -DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF -DSNAPPY_FUZZING_BUILD=OFF \
        -DSNAPPY_REQUIRE_AVX=OFF -DSNAPPY_REQUIRE_AVX2=OFF "${mycmake[@]}" ..
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-libsnappy
}

ffbuild_unconfigure() {
    echo --disable-libsnappy
}
