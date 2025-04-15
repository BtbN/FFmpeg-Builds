#!/bin/bash

SCRIPT_REPO="https://github.com/drobilla/sord.git"
SCRIPT_COMMIT="d588a2510d0ee071348f65c84334b035df22e0b1"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Ddocs=disabled
        -Dtools=disabled
        -Dtests=disabled
    )

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
