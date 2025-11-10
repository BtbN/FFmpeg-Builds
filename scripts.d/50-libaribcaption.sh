#!/bin/bash

SCRIPT_REPO="https://github.com/xqq/libaribcaption.git"
SCRIPT_COMMIT="27cf3cab26084d636905335d92c375ecbc3633ea"

ffbuild_depends() {
    echo base
    echo fonts
}

ffbuild_enabled() {
    [[ $ADDINS_STR == *4.4* ]] && return -1
    [[ $ADDINS_STR == *5.0* ]] && return -1
    [[ $ADDINS_STR == *5.1* ]] && return -1
    [[ $ADDINS_STR == *6.0* ]] && return -1

    return 0
}

ffbuild_dockerbuild() {
    build_cmake -G Ninja \
        -DARIBCC_SHARED_LIBRARY=OFF \
        -DARIBCC_BUILD_TESTS=OFF \
        -DARIBCC_USE_FREETYPE=ON \
        -DARIBCC_USE_EMBEDDED_FREETYPE=OFF

    add_pkgconfig_libs_private libaribcaption stdc++
}

ffbuild_configure() {
    echo --enable-libaribcaption
}

ffbuild_unconfigure() {
    [[ $ADDINS_STR == *4.4* ]] && return 0
    [[ $ADDINS_STR == *5.0* ]] && return 0
    [[ $ADDINS_STR == *5.1* ]] && return 0
    [[ $ADDINS_STR == *6.0* ]] && return 0

    echo --disable-libaribcaption
}
