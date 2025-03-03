#!/bin/bash

SCRIPT_REPO="https://github.com/tukaani-project/xz.git"
SCRIPT_COMMIT="4941ea454c02cf15a64d6434a0778fc2a81282fc"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    ./autogen.sh --no-po4a --no-doxygen

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-symbol-versions
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
}

ffbuild_configure() {
    echo --enable-lzma
}

ffbuild_unconfigure() {
    echo --disable-lzma
}
