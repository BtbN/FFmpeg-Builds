#!/bin/bash

SCRIPT_REPO="https://github.com/madler/zlib.git"
SCRIPT_COMMIT="ceadaf28dfa48dbf238a0ddb884d4c543b4170e8"

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
