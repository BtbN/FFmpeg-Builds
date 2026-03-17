#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/fontconfig/fontconfig.git"
SCRIPT_COMMIT="bf0ff2ce21f45596d078f3a9573abc9d9453d1e0"

ffbuild_depends() {
    echo base
    echo libxml2
    echo libiconv
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
        -Ddoc=disabled
        -Diconv=enabled
        -Dxml-backend=libxml2
        -Dtools=disabled
        -Dcache-build=disabled
        -Dtests=disabled
    )

    if [[ $TARGET == linux* ]]; then
        myconf+=(
            --sysconfdir=/etc
            --localstatedir=/var
            --cross-file=/cross.meson
        )
    elif [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    rm -rf "$FFBUILD_DESTPREFIX"/{var,share,etc}
}

ffbuild_configure() {
    echo --enable-fontconfig
}

ffbuild_unconfigure() {
    echo --disable-fontconfig
}
