#!/bin/bash

SCRIPT_REPO="https://github.com/harfbuzz/harfbuzz.git"
SCRIPT_COMMIT="17c80035adc61c52a9e9600664496e3e4b837e37"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" harfbuzz
    cd harfbuzz

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

    export LIBS="-lpthread"

    ./autogen.sh "${myconf[@]}"
    make -j$(nproc)
    make install
}
