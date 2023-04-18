#!/bin/bash

SCRIPT_REPO="https://git.savannah.gnu.org/git/libiconv.git"
SCRIPT_COMMIT="33f08ec1e0fc1e8203a3d81e9161894dc5793908"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    retry-tool sh -c "rm -rf iconv && git clone '$SCRIPT_REPO' iconv"
    cd iconv
    git checkout "$SCRIPT_COMMIT"

    ./gitsub.sh pull
    ./autogen.sh

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
