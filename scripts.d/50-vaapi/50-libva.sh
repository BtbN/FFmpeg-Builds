#!/bin/bash

SCRIPT_REPO="https://github.com/intel/libva.git"
SCRIPT_COMMIT="63d2b2232148a493d6a5b385a1ebbbd3fa37ece3"

ffbuild_enabled() {
    [[ $ADDINS_STR == *4.4* && $TARGET == win* ]] && return -1
    [[ $ADDINS_STR == *5.0* && $TARGET == win* ]] && return -1
    [[ $ADDINS_STR == *5.1* && $TARGET == win* ]] && return -1
    [[ $ADDINS_STR == *6.0* && $TARGET == win* ]] && return -1
    [[ $TARGET == linuxarm64 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR/$SELF"

    # This works around an issue of our libxcb-dri3 implib-wrapper not exporting data symbols.
    # Under normal circumstances, this would break horribly.
    # But we only want to generate another import lib for libva, so it doesn't matter.
    echo "#include <xcb/xcbext.h>" >> va/x11/va_dri3.c
    echo "xcb_extension_t xcb_dri3_id;" >> va/x11/va_dri3.c

    # Allow to actually toggle static linking
    sed -i "s/shared_library/library/g" va/meson.build

    mkdir mybuild && cd mybuild

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Denable_docs=false
    )

    if [[ $TARGET == linux64 ]]; then
        myconf+=(
            --cross-file=/cross.meson
            --default-library=shared
            --sysconfdir="/etc"
            -Ddriverdir="/usr/lib/x86_64-linux-gnu/dri"
            -Ddisable_drm=false
            -Dwith_x11=yes
            -Dwith_glx=no
            -Dwith_wayland=no
        )
    elif [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
            --default-library=static
            -Dwith_win32=yes
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAFS="$RAW_LDFLAGS"

    meson "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install

    if [[ $TARGET == linux* ]]; then
        gen-implib "$FFBUILD_PREFIX"/lib/{libva.so.2,libva.a}
        gen-implib "$FFBUILD_PREFIX"/lib/{libva-drm.so.2,libva-drm.a}
        gen-implib "$FFBUILD_PREFIX"/lib/{libva-x11.so.2,libva-x11.a}
        rm "$FFBUILD_PREFIX"/lib/libva{,-drm,-x11}.so*

        echo "Libs: -ldl" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libva.pc
    fi
}

ffbuild_configure() {
    echo --enable-vaapi
}

ffbuild_unconfigure() {
    echo --disable-vaapi
}
