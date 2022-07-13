#!/bin/bash

SCRIPT_REPO="https://github.com/drobilla/serd.git"
SCRIPT_COMMIT="2465c3f2779617658cf85d3cbc0ca7b786a4ddca"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" serd
    cd serd

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

    sed -i 's/Cflags:/Cflags: -DSERD_STATIC/' "$FFBUILD_PREFIX"/lib/pkgconfig/serd-0.pc
}
