#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/libudfread.git"
SCRIPT_COMMIT="139a2194525f2745b98a98e4d8fa627d07440176"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    # stop the static library from exporting symbols when linked into a shared lib
    sed -i 's/-DUDFREAD_API_EXPORT/-DUDFREAD_API_EXPORT_DISABLED/g' src/meson.build

    build_meson -Denable_examples=false

    ln -s libudfread.pc "$FFBUILD_DESTPREFIX"/lib/pkgconfig/udfread.pc
}
