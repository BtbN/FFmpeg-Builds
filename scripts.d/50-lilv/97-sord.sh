#!/bin/bash

SORD_REPO="https://github.com/drobilla/sord.git"
SORD_COMMIT="d2efdb2d026216449599350b55c2c85c0d3efb89"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SORD_REPO" "$SORD_COMMIT" sord
    cd sord
    git submodule update --init --recursive --depth 1

    local mywaf=(
        --prefix="$FFBUILD_PREFIX"
        --no-utils
        --static
        --no-shared
    )

    CC="${FFBUILD_CROSS_PREFIX}gcc" CXX="${FFBUILD_CROSS_PREFIX}g++" ./waf configure "${mywaf[@]}"
    ./waf -j$(nproc)
    ./waf install

    sed -i 's/Cflags:/Cflags: -DSORD_STATIC/' "$FFBUILD_PREFIX"/lib/pkgconfig/sord-0.pc
}
