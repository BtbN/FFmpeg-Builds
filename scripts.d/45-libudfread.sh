#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/libudfread.git"
SCRIPT_COMMIT="139a2194525f2745b98a98e4d8fa627d07440176"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    # stop the static library from exporting symbols when linked into a shared lib
    sed -i 's/-DUDFREAD_API_EXPORT/-DUDFREAD_API_EXPORT_DISABLED/g' src/meson.build

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        -Ddefault_library=static
        -Denable_examples=false
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

    ln -s libudfread.pc "$FFBUILD_DESTPREFIX"/lib/pkgconfig/udfread.pc
}
