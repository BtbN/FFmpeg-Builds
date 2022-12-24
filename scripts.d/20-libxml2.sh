#!/bin/bash

SCRIPT_REPO="https://gitlab.gnome.org/GNOME/libxml2.git"
SCRIPT_COMMIT="c885bebb5d423b3faad21e62d9b962e824feaf93"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" libxml2
    cd libxml2

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
