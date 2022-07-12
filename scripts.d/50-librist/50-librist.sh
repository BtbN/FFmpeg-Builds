#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/rist/librist.git"
SCRIPT_COMMIT="809390b3b75a259a704079d0fb4d8f1b5f7fa956"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" librist
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
