#!/bin/bash

DAV1D_REPO="https://code.videolan.org/videolan/dav1d.git"
DAV1D_COMMIT="2c09aaa4d7e0f96ca5a4cdefb6a04d0cf7e0bf4b"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
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

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" .. || return -1
    ninja -j$(nproc) || return -1
    ninja install || return -1

    cd ../..
    rm -rf dav1d
}

ffbuild_configure() {
    echo --enable-libdav1d
}

ffbuild_unconfigure() {
    echo --disable-libdav1d
}
