#!/bin/bash

LIBVA_REPO="https://github.com/intel/libva.git"
LIBVA_COMMIT="9e4bdc5c4f7f8549187badb8a5111c1b07c3c41c"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBVA_REPO" "$LIBVA_COMMIT" libva
    cd libva

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-shared
        --disable-static
        --with-pic
        --disable-docs
        --enable-drm
        --enable-x11
        --disable-glx
        --disable-wayland
    )

    if [[ $TARGET == linux64 ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
            --with-drivers-path="/usr/lib/x86_64-linux-gnu/dri"
            --sysconfdir="/etc"
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAFS="$RAW_LDFLAGS"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    gen-implib "$FFBUILD_PREFIX"/lib/{libva.so.2,libva.a}
    gen-implib "$FFBUILD_PREFIX"/lib/{libva-drm.so.2,libva-drm.a}
    gen-implib "$FFBUILD_PREFIX"/lib/{libva-x11.so.2,libva-x11.a}
    rm "$FFBUILD_PREFIX"/lib/libva{,-drm,-x11}{.so*,.la}

    echo "Libs: -ldl" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libva.pc
}

ffbuild_configure() {
    echo --enable-vaapi
}

ffbuild_unconfigure() {
    echo --disable-vaapi
}
