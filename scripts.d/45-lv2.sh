#!/bin/bash

LV2_REPO="https://gitlab.com/lv2/lv2.git"
LV2_COMMIT="ba34a58b32839491335b5bcbda46e11c4b209cbc"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$LV2_REPO" "$LV2_COMMIT" lv2
    cd lv2
    git submodule update --init --recursive --depth 1

    local mywaf=(
        --prefix="$FFBUILD_PREFIX"
        --no-plugins
        --no-coverage
    )

    CC="${FFBUILD_CROSS_PREFIX}gcc" CXX="${FFBUILD_CROSS_PREFIX}g++" ./waf configure "${mywaf[@]}"
    ./waf -j$(nproc)
    ./waf install

    cd ..
    rm -rf lv2
}
