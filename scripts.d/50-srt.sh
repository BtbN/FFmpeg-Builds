#!/bin/bash

SCRIPT_REPO="https://github.com/Haivision/srt.git"
SCRIPT_COMMIT="c09532f8edf28de91854f975bb16e643e8085ed9"

ffbuild_depends() {
    echo base
    echo openssl
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    build_cmake \
        -DENABLE_CXX_DEPS=ON \
        -DUSE_STATIC_LIBSTDCXX=ON \
        -DENABLE_ENCRYPTION=ON \
        -DENABLE_APPS=OFF

    add_pkgconfig_libs_private srt stdc++
}

ffbuild_configure() {
    echo $(ffbuild_enable libsrt)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libsrt)
}
