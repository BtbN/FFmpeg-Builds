#!/bin/bash

SCRIPT_REPO="https://github.com/fribidi/fribidi.git"
SCRIPT_COMMIT="b28f43bd3e8e31a5967830f721bab218c1aa114c"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    build_meson \
        -Dbin=false \
        -Ddocs=false \
        -Dtests=false

    sed -i 's/Cflags:/Cflags: -DFRIBIDI_LIB_STATIC/' "$FFBUILD_DESTPREFIX"/lib/pkgconfig/fribidi.pc
}

ffbuild_configure() {
    echo $(ffbuild_enable libfribidi)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libfribidi)
}
