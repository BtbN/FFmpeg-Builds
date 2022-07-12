#!/bin/bash

SCRIPT_REPO="https://github.com/lv2/lilv.git"
SCRIPT_COMMIT="c36d3451278555134de850fc548d743b6da2179a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" lilv
    cd lilv
    git submodule update --init --recursive --depth 1

    local mywaf=(
        --prefix="$FFBUILD_PREFIX"
        --static
        --no-shared
        --no-bindings
        --no-utils
        --no-bash-completion
    )

    CC="${FFBUILD_CROSS_PREFIX}gcc" CXX="${FFBUILD_CROSS_PREFIX}g++" ./waf configure "${mywaf[@]}"
    ./waf -j$(nproc)
    ./waf install

    sed -i 's/Cflags:/Cflags: -DLILV_STATIC/' "$FFBUILD_PREFIX"/lib/pkgconfig/lilv-0.pc
}

ffbuild_configure() {
    echo --enable-lv2
}

ffbuild_unconfigure() {
    echo --disable-lv2
}
