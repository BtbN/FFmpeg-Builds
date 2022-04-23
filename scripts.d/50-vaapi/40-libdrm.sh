#!/bin/bash

LIBDRM_REPO="https://gitlab.freedesktop.org/mesa/drm.git"
LIBDRM_COMMIT="d95b12e7e3ed6a22f284afbc5d2356365b820ea8"

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
        -Ddefault_library=shared
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

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAFS="$RAW_LDFLAGS"

    meson "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install

    gen-implib "$FFBUILD_PREFIX"/lib/{libdrm.so.2,libdrm.a}
    rm "$FFBUILD_PREFIX"/lib/libdrm*.so*

    echo "Libs: -ldl" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libdrm.pc
}

ffbuild_configure() {
    echo --enable-libdrm
}

ffbuild_unconfigure() {
    echo --disable-libdrm
}
