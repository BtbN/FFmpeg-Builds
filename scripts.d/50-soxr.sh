#!/bin/bash

# https://sourceforge.net/p/soxr/code/ci/master/tree/
SOXR_REPO="https://git.code.sf.net/p/soxr/code"
SOXR_COMMIT="945b592b70470e29f917f4de89b4281fbbd540c0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$SOXR_REPO" "$SOXR_COMMIT" soxr
    cd soxr

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=OFF ..
    make -j$(nproc)
    make install

    cd ../..
    rm -rf soxr
}

ffbuild_configure() {
    echo --enable-libsoxr
}

ffbuild_unconfigure() {
    echo --disable-libsoxr
}

ffbuild_ldflags() {
    echo -pthread
}

ffbuild_libs() {
    echo -lgomp
}
