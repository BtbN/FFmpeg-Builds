#!/bin/bash

SCRIPT_REPO="https://github.com/vapoursynth/vapoursynth.git"
SCRIPT_COMMIT="R80"
SCRIPT_TAGFILTER="R[0-9][0-9]"

ffbuild_enabled() {
    # Older FFmpeg links the VSScript library instead of loading it at runtime
    (( $(ffbuild_ffver) >= 701 )) || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir -p "$FFBUILD_DESTPREFIX"/include/vapoursynth "$FFBUILD_DESTPREFIX"/lib/pkgconfig
    cp include/*.h "$FFBUILD_DESTPREFIX"/include/vapoursynth

    cat >"$FFBUILD_DESTPREFIX"/lib/pkgconfig/vapoursynth.pc <<EOF
prefix=$FFBUILD_PREFIX
includedir=\${prefix}/include/vapoursynth

Name: vapoursynth
Description: A frameserver for the 21st century
Version: $(awk '{print $3}' VAPOURSYNTH_VERSION)
Cflags: -I\${includedir}
EOF
}

ffbuild_configure() {
    echo --enable-vapoursynth
}

ffbuild_unconfigure() {
    echo --disable-vapoursynth
}
