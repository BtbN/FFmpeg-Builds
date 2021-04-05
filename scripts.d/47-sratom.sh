#!/bin/bash

SRATOM_REPO="https://github.com/lv2/sratom.git"
SRATOM_COMMIT="c46452c83d442de137fa6470ba544e3ba142e923"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SRATOM_REPO" "$SRATOM_COMMIT" sratom
    cd sratom
    git submodule update --init --recursive --depth 1

    local mywaf=(
        --prefix="$FFBUILD_PREFIX"
        --static
        --no-shared
    )

    CC="${FFBUILD_CROSS_PREFIX}gcc" CXX="${FFBUILD_CROSS_PREFIX}g++" ./waf configure "${mywaf[@]}"
    ./waf -j$(nproc)
    ./waf install

    sed -i 's/Cflags:/Cflags: -DSRATOM_STATIC/' "$FFBUILD_PREFIX"/lib/pkgconfig/sratom-0.pc
}
