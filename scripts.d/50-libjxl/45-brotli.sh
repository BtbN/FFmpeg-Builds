#!/bin/bash

SCRIPT_REPO="https://github.com/google/brotli.git"
SCRIPT_COMMIT="fa925d0c1559a582d654a9fd2adfd83e317145fa"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    build_cmake -G Ninja -DCMAKE_POSITION_INDEPENDENT_CODE=ON
}
