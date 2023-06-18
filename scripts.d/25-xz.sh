#!/bin/bash

SCRIPT_REPO="https://github.com/xz-mirror/xz.git"
SCRIPT_COMMIT="1dbe12b90cff79bb51923733ac0840747b4b4131"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR/$SELF"

    ./autogen.sh --no-po4a

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
