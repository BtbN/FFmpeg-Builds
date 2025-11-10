#!/bin/bash

SCRIPT_REPO="https://github.com/harfbuzz/harfbuzz.git"
SCRIPT_COMMIT="41c8b99beef781f42f7fce7ec75efac80c815b85"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    local extra_opts=(
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
        extra_opts+=(-Dgdi=enabled)
    fi

    build_meson "${extra_opts[@]}"

    add_pkgconfig_libs_private harfbuzz pthread
}

ffbuild_configure() {
    (( $(ffbuild_ffver) > 600 )) || return 0
    echo --enable-libharfbuzz
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) > 600 )) || return 0
    echo --disable-libharfbuzz
}
