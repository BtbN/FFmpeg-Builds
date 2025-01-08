#!/bin/bash

SCRIPT_REPO="https://github.com/harfbuzz/harfbuzz.git"
SCRIPT_COMMIT="b5a65e0f20c30a7f13b2f6619479a6d666e603e0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --cross-file=/cross.meson
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Dfreetype=enabled
        -Dglib=disabled
        -Dgobject=disabled
        -Dcairo=disabled
        -Dchafa=disabled
        -Dtests=disabled
        -Dintrospection=disabled
        -Ddocs=disabled
        -Ddoc_tests=false
        -Dutilities=disabled
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            -Dgdi=enabled
        )
    fi

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install

    echo "Libs.private: -lpthread" >> "$FFBUILD_PREFIX"/lib/pkgconfig/harfbuzz.pc
}

ffbuild_configure() {
    (( $(ffbuild_ffver) > 600 )) || return 0
    echo --enable-libharfbuzz
}
