#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/libdvdread.git"
SCRIPT_COMMIT="a66aec4dd722dbfed0be3e26eb36270cea5d2df6"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    (( $(ffbuild_ffver) >= 700 )) || return -1
    return 0
}

ffbuild_dockerbuild() {
    # stop the static library from exporting symbols when linked into a shared lib
    sed -i 's/-DDVDREAD_API_EXPORT/-DDVDREAD_API_EXPORT_DISABLED/g' src/meson.build

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        -Ddefault_library=static
        -Denable_docs=false
        -Dlibdvdcss=enabled
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
}

ffbuild_configure() {
    echo --enable-libdvdread
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) >= 700 )) || return 0
    echo --disable-libdvdread
}
