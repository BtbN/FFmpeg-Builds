#!/bin/bash

SCRIPT_REPO="https://github.com/madler/zlib.git"
SCRIPT_COMMIT="5a82f71ed1dfc0bec044d9702463dbdf84ea3b71"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --static
    )

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-zlib
}

ffbuild_unconfigure() {
    echo --disable-zlib
}
