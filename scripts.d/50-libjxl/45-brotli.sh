#!/bin/bash

SCRIPT_REPO="https://github.com/google/brotli.git"
SCRIPT_COMMIT="390de5b472ec8c40a7b8e5029e47fd6493f7a755"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    build_cmake -G Ninja -DCMAKE_POSITION_INDEPENDENT_CODE=ON
}
