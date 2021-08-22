#!/bin/bash

LIBDRM_REPO="https://gitlab.freedesktop.org/mesa/drm.git"
LIBDRM_COMMIT="1a4c0ec9aea13211997f982715fe5ffcf19dd067"

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
