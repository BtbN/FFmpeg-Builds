#!/bin/bash

SCRIPT_REPO="https://git.savannah.gnu.org/git/libiconv.git"
SCRIPT_COMMIT="5448df580c4287b7bfe59d3be0dcbb2227e641d1"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    retry-tool sh -c "rm -rf iconv && git clone '$SCRIPT_REPO' iconv"
    cd iconv
    git checkout "$SCRIPT_COMMIT"

    retry-tool ./autopull.sh --one-time
    (unset CC CFLAGS GMAKE && ./autogen.sh)

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-extra-encodings
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
    echo --enable-iconv
}

ffbuild_unconfigure() {
    echo --disable-iconv
}
