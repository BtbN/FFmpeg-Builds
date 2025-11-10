#!/bin/bash

SCRIPT_REPO="https://github.com/google/snappy.git"
SCRIPT_COMMIT="cbea40d40c61c442be7ee0c9695b45ea1b5a3c8c"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    build_cmake \
        -DSNAPPY_BUILD_TESTS=OFF \
        -DSNAPPY_BUILD_BENCHMARKS=OFF \
        -DSNAPPY_FUZZING_BUILD=OFF \
        -DSNAPPY_REQUIRE_AVX=OFF \
        -DSNAPPY_REQUIRE_AVX2=OFF
}

ffbuild_configure() {
    echo $(ffbuild_enable libsnappy)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libsnappy)
}
