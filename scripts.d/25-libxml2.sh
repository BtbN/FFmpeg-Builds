#!/bin/bash

SCRIPT_REPO="https://github.com/GNOME/libxml2.git"
SCRIPT_COMMIT="62d4697db6268b71e36ef8fda708953cadf4082a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --without-python
        --disable-maintainer-mode
        --disable-shared
        --enable-static
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./autogen.sh "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libxml2
}

ffbuild_unconfigure() {
    echo --disable-libxml2
}
