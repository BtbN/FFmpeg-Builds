#!/bin/bash

SCRIPT_REPO="https://github.com/acoustid/chromaprint.git"
SCRIPT_COMMIT="9b6a0c61ecbeab75271bab4aca651d8dff41c5d6"

ffbuild_depends() {
    echo base
    echo fftw3
}

ffbuild_enabled() {
    # pkg-config check is currently only available in master
    [[ $ADDINS_STR == *4.4* ]] && return -1
    [[ $ADDINS_STR == *5.0* ]] && return -1
    [[ $ADDINS_STR == *5.1* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    build_cmake \
        -DBUILD_TOOLS=OFF \
        -DBUILD_TESTS=OFF \
        -DFFT_LIB=fftw3

    add_pkgconfig_libs_private libchromaprint fftw3 stdc++
    add_pkgconfig_cflags_private libchromaprint "-DCHROMAPRINT_NODLL"
}

ffbuild_configure() {
    echo $(ffbuild_enable chromaprint)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable chromaprint)
}
