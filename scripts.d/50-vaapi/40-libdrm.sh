#!/bin/bash

LIBDRM_REPO="https://gitlab.freedesktop.org/mesa/drm.git"
LIBDRM_COMMIT="a97f265c7dc1924a38a899082caf97519f8c532e"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBDRM_REPO" "$LIBDRM_COMMIT" libdrm
    cd libdrm

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        -Ddefault_library=static
        -Dlibkms=false
        -Dudev=false
        -Dcairo-tests=false
        -Dvalgrind=false
        -Dexynos=false
        -Dfreedreno=false
        -Domap=false
        -Detnaviv=false
        -Dintel=true
        -Dnouveau=true
        -Dradeon=true
        -Damdgpu=true
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
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libdrm
}

ffbuild_unconfigure() {
    echo --disable-libdrm
}
