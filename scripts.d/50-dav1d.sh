#!/bin/bash

DAV1D_REPO="https://code.videolan.org/videolan/dav1d.git"
DAV1D_COMMIT="3bfe8c7c8a553728e2d6556e4a95f5cd246d1c92"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git clone "$DAV1D_REPO" dav1d || return -1
    cd dav1d
    git checkout "$DAV1D_COMMIT" || return -1

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
    )

    if [[ $TARGET == win64 ]]; then
        myconf+=(
            --cross-file=../package/crossfiles/x86_64-w64-mingw32.meson
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
