#!/bin/bash

WEBP_REPO="https://chromium.googlesource.com/webm/libwebp"
WEBP_COMMIT="cf847cba5845030fb906cff1006f37f4b28ca73a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$WEBP_REPO" "$WEBP_COMMIT" webp
    cd webp

    ./autogen.sh || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --enable-libwebpmux
        --disable-libwebpextras
        --disable-libwebpdemux
        --disable-sdl
        --disable-gl
        --disable-png
        --disable-jpeg
        --disable-tiff
        --disable-gif
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ..
    rm -rf webp
}

ffbuild_configure() {
    echo --enable-libwebp
}

ffbuild_unconfigure() {
    echo --disable-libwebp
}
