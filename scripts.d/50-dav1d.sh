#!/bin/bash

DAV1D_REPO="https://code.videolan.org/videolan/dav1d.git"
DAV1D_COMMIT="887fa1d718df42aac1ac102580c14eb655979ac6"

ffbuild_enabled() {
    return -1
}

ffbuild_dockerbuild() {
    git-mini-clone "$DAV1D_REPO" "$DAV1D_COMMIT" dav1d
    cd dav1d

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
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
}

ffbuild_configure() {
    echo --enable-libdav1d
}

ffbuild_unconfigure() {
    echo --disable-libdav1d
}
