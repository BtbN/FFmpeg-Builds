#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/rist/librist.git"
SCRIPT_COMMIT="6cb9b99f55076dffb84fe4a31c773aeb2d7e52ca"

ffbuild_enabled() {
    (( $(ffbuild_ffver) >= 404 )) || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Duse_mbedtls=true
        -Dbuiltin_mbedtls=false
        -Dbuilt_tools=false
        -Dtest=false
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            -Dhave_mingw_pthreads=true
        )
    fi

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" ..
    ninja -j"$(nproc)"
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    echo "Requires: mbedcrypto" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/librist.pc
}

ffbuild_configure() {
    echo --enable-librist
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) >= 404 )) || return 0
    echo --disable-librist
}
