#!/bin/bash

SCRIPT_REPO="https://github.com/lu-zero/mfx_dispatch.git"
SCRIPT_COMMIT="7e4d221c36c630c1250b23a5dfa15657bc04c10c"

ffbuild_enabled() {
    [[ $TARGET == linuxarm64 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" mfx
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
