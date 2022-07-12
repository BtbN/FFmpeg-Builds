#!/bin/bash

SCRIPT_REPO="https://github.com/drobilla/sord.git"
SCRIPT_COMMIT="ee631481ba7cbe5f6afdf5dd00860eb9bbed57f4"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" sord
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
