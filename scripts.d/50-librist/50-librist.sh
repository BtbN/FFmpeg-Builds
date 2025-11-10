#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/rist/librist.git"
SCRIPT_COMMIT="1a5013b59ce098465e835a0510cd395872bb1c24"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    local extra_opts=(
        -Duse_mbedtls=true
        -Dbuiltin_mbedtls=false
        -Dbuilt_tools=false
        -Dtest=false
    )

    if [[ $TARGET == win* ]]; then
        extra_opts+=(-Dhave_mingw_pthreads=true)
    fi

    build_meson "${extra_opts[@]}"

    echo "Requires: mbedcrypto" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/librist.pc
}

ffbuild_configure() {
    echo $(ffbuild_enable librist)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable librist)
}
