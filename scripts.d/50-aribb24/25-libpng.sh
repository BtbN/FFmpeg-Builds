#!/bin/bash

SCRIPT_REPO="https://github.com/glennrp/libpng.git"
SCRIPT_COMMIT="c1cc0f3f4c3d4abd11ca68c59446a29ff6f95003"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
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

    export CPPFLAGS="$CPPFLAGS -I$FFBUILD_PREFIX/include"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}
