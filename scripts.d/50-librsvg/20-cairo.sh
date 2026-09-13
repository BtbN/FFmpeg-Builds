#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/cairo/cairo.git"
SCRIPT_COMMIT="dd6262c17e6537fe992f3b17748578093392dac0"

ffbuild_depends() {
    echo base
    echo zlib
    echo libpng
    echo pixman
    echo fonts
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    sed -i 's/__attribute__((__visibility__("default")))//' src/cairo.h

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        --wrap-mode=nodownload
        -Dglib=enabled
        -Dpng=enabled
        -Dzlib=enabled
        -Dfreetype=enabled
        -Dfontconfig=enabled
        -Dxlib=disabled
        -Dxcb=disabled
        -Dxlib-xcb=disabled
        -Dtee=disabled
        -Dlzo=disabled
        -Dspectre=disabled
        -Dsymbol-lookup=disabled
        -Dgtk2-utils=disabled
        -Dtests=disabled
        -Dgtk_doc=false
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson setup "${myconf[@]}" ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    if [[ $TARGET == win* ]]; then
        echo "Cflags: -DCAIRO_WIN32_STATIC_BUILD" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/cairo.pc
        # The DWrite backend is C++ and COM
        echo "Libs: -lole32 -lstdc++" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/cairo.pc
    fi
}
