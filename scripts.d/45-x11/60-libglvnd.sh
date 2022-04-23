#!/bin/bash

GLVND_REPO="https://gitlab.freedesktop.org/glvnd/libglvnd.git"
GLVND_COMMIT="5024e5796ea16baf6f9203b1414c870a30b20474"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$GLVND_REPO" "$GLVND_COMMIT" glvnd
    cd glvnd

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Dasm=enabled
        -Dx11=enabled
        -Degl=true
        -Dglx=enabled
        -Dgles1=true
        -Dgles2=true
        -Dheaders=true
    )

    if [[ $TARGET == linux* ]]; then
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
