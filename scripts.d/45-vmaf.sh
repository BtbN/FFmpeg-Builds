#!/bin/bash

SCRIPT_REPO="https://github.com/Netflix/vmaf.git"
SCRIPT_COMMIT="e0d9b82d3b55de55927f1e7e7bd11f40a35de3e0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    # Kill build of unused and broken tools
    echo > libvmaf/tools/meson.build

    build_meson \
        -Dbuilt_in_models=true \
        -Denable_tests=false \
        -Denable_docs=false \
        -Denable_avx512=true \
        -Denable_float=true \
        libvmaf

    add_pkgconfig_libs_private libvmaf stdc++
}

ffbuild_configure() {
    [[ $ADDINS_STR == *4.4* ]] && return 0
    [[ $ADDINS_STR == *5.0* ]] && return 0
    echo --enable-libvmaf
}

ffbuild_unconfigure() {
    echo --disable-libvmaf
}
