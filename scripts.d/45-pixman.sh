#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/pixman/pixman.git"
SCRIPT_COMMIT="e7fd44140fe6edef507d54bdbc25c09543ffc936"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Dgtk=disabled
        -Dlibpng=disabled
        -Dopenmp=disabled
        -Dtests=disabled
        -Ddemos=disabled
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson setup "${myconf[@]}" ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}
