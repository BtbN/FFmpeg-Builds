#!/bin/bash

SCRIPT_REPO="https://github.com/Haivision/srt.git"
SCRIPT_COMMIT="a26a7021a501e8c4bc17c75f3a109cca529cf262"

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
