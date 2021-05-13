#!/bin/bash

# https://sourceforge.net/p/soxr/code/ci/master/tree/
SOXR_REPO="https://git.code.sf.net/p/soxr/code"
SOXR_COMMIT="945b592b70470e29f917f4de89b4281fbbd540c0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SOXR_REPO" "$SOXR_COMMIT" soxr
    cd soxr

    mkdir build && cd build

    if [[ $VARIANT == *shared* && $TARGET == linux* ]]; then
       USE_OMP="OFF"
    else
       USE_OMP="ON"
    fi

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DWITH_OPENMP="$USE_OMP" -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=OFF ..
    make -j$(nproc)
    make install
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
    [[ $VARIANT == *shared* && $TARGET == linux* ]] || echo -lgomp
}
