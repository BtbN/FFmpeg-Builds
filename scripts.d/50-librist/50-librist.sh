#!/bin/bash

LIBRIST_REPO="https://code.videolan.org/rist/librist.git"
LIBRIST_COMMIT="6356dde85e97398be8b60a44ee4341e847ce4d5f"

ffbuild_enabled() {
    return -1
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBRIST_REPO" "$LIBRIST_COMMIT" librist
    cd librist

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
    ninja install
}

ffbuild_configure() {
    echo --enable-librist
}

ffbuild_unconfigure() {
    echo --disable-librist
}
