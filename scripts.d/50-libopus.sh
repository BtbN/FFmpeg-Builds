#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/opus.git"
SCRIPT_COMMIT="8cf872a186b96085b1bb3a547afd598354ebeb87"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" opus
    cd opus

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --disable-extra-programs
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
    echo --enable-libopus
}

ffbuild_unconfigure() {
    echo --disable-libopus
}
