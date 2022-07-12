#!/bin/bash

SCRIPT_REPO="https://github.com/lv2/sratom.git"
SCRIPT_COMMIT="8cf09feee6895ba0760f8c24db6416dac9006dc3"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" sratom
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
