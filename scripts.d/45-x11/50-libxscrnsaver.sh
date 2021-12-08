#!/bin/bash

LIBXSCRNSAVER_REPO="https://gitlab.freedesktop.org/xorg/lib/libxscrnsaver.git"
LIBXSCRNSAVER_COMMIT="aa9fd5061d0a8832480ad0c1acc9d2e864e807f4"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBXSCRNSAVER_REPO" "$LIBXSCRNSAVER_COMMIT" libxscrnsaver
    cd libxscrnsaver

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == linux* ]]; then
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
