#!/bin/bash

SCRIPT_REPO="https://github.com/intel/libva.git"
SCRIPT_COMMIT="7d6c7d482b9d2330b1f3a8bac13a6a3205f33382"

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

    mkdir mybuild && cd mybuild

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=shared
        -Denable_docs=false
    )

    if [[ $TARGET == linux64 ]]; then
        myconf+=(
            --cross-file=/cross.meson
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
    elif [[ $TARGET == win* ]]; then
        "$FFBUILD_CROSS_PREFIX"gendef - "$FFBUILD_PREFIX"/bin/libva.dll > libva.def
        "$FFBUILD_CROSS_PREFIX"gendef - "$FFBUILD_PREFIX"/bin/libva_win32.dll > libva_win32.def
        "$FFBUILD_CROSS_PREFIX"dlltool --input-def libva.def --output-delaylib "$FFBUILD_PREFIX"/lib/libva.a
        "$FFBUILD_CROSS_PREFIX"dlltool --input-def libva_win32.def --output-delaylib "$FFBUILD_PREFIX"/lib/libva_win32.a
        rm "$FFBUILD_PREFIX"/bin/libva*.dll "$FFBUILD_PREFIX"/lib/libva*.dll.a
    else
        echo "Unknown target"
        return -1
    fi
}

ffbuild_configure() {
    echo --enable-vaapi
}

ffbuild_unconfigure() {
    echo --disable-vaapi
}
