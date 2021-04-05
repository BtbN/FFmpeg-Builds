#!/bin/bash

MFX_REPO="https://github.com/lu-zero/mfx_dispatch.git"
MFX_COMMIT="2cd279f1e8a277c843025c8713c6ed3b4c42b032"

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

    if [[ $TARGET == win* ]]; then
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
}

ffbuild_configure() {
    echo --enable-libmfx
}

ffbuild_unconfigure() {
    echo --disable-libmfx
}
