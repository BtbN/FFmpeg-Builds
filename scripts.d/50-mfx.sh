#!/bin/bash

MFX_REPO="https://github.com/lu-zero/mfx_dispatch.git"
MFX_COMMIT="7e4d221c36c630c1250b23a5dfa15657bc04c10c"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$MFX_REPO" "$MFX_COMMIT" mfx
    cd mfx

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    ln -s libmfx.pc "$FFBUILD_PREFIX"/lib/pkgconfig/mfx.pc
}

ffbuild_configure() {
    echo --enable-libmfx
}

ffbuild_unconfigure() {
    echo --disable-libmfx
}
