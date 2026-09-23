#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/glvnd/libglvnd.git"
SCRIPT_COMMIT="c046a760d845416e98ac4128757b2b356c47fdaa"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Dasm=enabled
        -Dx11=enabled
        -Degl=true
        -Dglx=enabled
        -Dgles1=true
        -Dgles2=true
        -Dheaders=true
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
    ninja -j"$(nproc)"
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    for LIB in libGL.so.1 libGLX.so.0 libOpenGL.so.0 libEGL.so.1 libGLESv1_CM.so.1 libGLESv2.so.2; do
        gen-implib "$FFBUILD_DESTPREFIX"/lib/{"${LIB}","${LIB%%.*}.a"}
        rm "$FFBUILD_DESTPREFIX"/lib/"${LIB%%.*}".so*
    done

    for LIB in gl glx opengl egl glesv1_cm glesv2; do
        echo "Libs: -ldl" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/"${LIB}".pc
    done
}
