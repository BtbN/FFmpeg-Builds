#!/bin/bash

OPENH264_REPO="https://github.com/cisco/openh264.git"
OPENH264_COMMIT="40913c2a3a10fa3b8dc9e7685214ba1bf19fd11b"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$OPENH264_REPO" "$OPENH264_COMMIT" openh264
    cd openh264

    mkdir bdir && cd bdir

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Dtests=disabled
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install

    if [[ $TARGET == win* ]]; then
        rm "$FFBUILD_PREFIX"/{lib,bin}/libopenh264*.dll*
    else
        rm "$FFBUILD_PREFIX"/lib/libopenh264*.so*
    fi
}

ffbuild_configure() {
    echo --enable-libopenh264
}

ffbuild_unconfigure() {
    echo --disable-libopenh264
}
