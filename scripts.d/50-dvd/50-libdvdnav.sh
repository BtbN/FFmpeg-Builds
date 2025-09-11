#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/libdvdnav.git"
SCRIPT_COMMIT="310adf98ffeae4977d9f74478bf44d3bc5b99d4f"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $ADDINS_STR == *4.4* ]] && return -1
    [[ $ADDINS_STR == *5.0* ]] && return -1
    [[ $ADDINS_STR == *5.1* ]] && return -1
    [[ $ADDINS_STR == *6.0* ]] && return -1
    [[ $ADDINS_STR == *6.1* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    # stop the static library from exporting symbols when linked into a shared lib
    sed -i 's/SUPPORT_ATTRIBUTE_VISIBILITY_DEFAULT/SUPPORT_ATTRIBUTE_VISIBILITY_DEFAULT_DISABLED/g' meson.build
    sed -i 's/-DLIBDVDCSS_EXPORTS/-DLIBDVDCSS_EXPORTS_DISABLED/g' src/meson.build

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        -Ddefault_library=static
        -Denable_docs=false
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
}

ffbuild_configure() {
    echo --enable-libdvdnav
}

ffbuild_unconfigure() {
    [[ $ADDINS_STR == *4.4* ]] && return 0
    [[ $ADDINS_STR == *5.0* ]] && return 0
    [[ $ADDINS_STR == *5.1* ]] && return 0
    [[ $ADDINS_STR == *6.0* ]] && return 0
    [[ $ADDINS_STR == *6.1* ]] && return 0
    echo --disable-libdvdnav
}
