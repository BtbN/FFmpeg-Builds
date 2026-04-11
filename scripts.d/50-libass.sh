#!/bin/bash

SCRIPT_REPO="https://github.com/libass/libass.git"
SCRIPT_COMMIT="fadc390583f24eb5cf98f16925fd3adee50bca88"

ffbuild_depends() {
    echo base
    echo fonts
    echo fribidi
    echo libiconv
    echo libunibreak
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Dtest=disabled
        -Dcompare=disabled
        -Dprofile=disabled
        -Dfuzz=disabled
        -Dcheckasm=disabled
        -Dfontconfig=enabled
        -Dasm=enabled
        -Dlibunibreak=enabled
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            -Ddirectwrite=enabled
            --cross-file=/cross.meson
        )
    elif [[ $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$CFLAGS -Dread_file=libass_internal_read_file"

    meson setup "${myconf[@]}" ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}

ffbuild_configure() {
    echo --enable-libass
}

ffbuild_unconfigure() {
    echo --disable-libass
}
