#!/bin/bash

SCRIPT_REPO="https://github.com/lv2/lv2.git"
SCRIPT_COMMIT="238ee61ef742d6a7627ebecd30f0f53b0c8d01de"

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
        -Dplugins=disabled
        -Dtests=disabled
        -Donline_docs=false
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
