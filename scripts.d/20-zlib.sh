#!/bin/bash

SCRIPT_REPO="https://github.com/madler/zlib.git"
SCRIPT_COMMIT="f9dd6009be3ed32415edf1e89d1bc38380ecb95d"

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
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-zlib
}

ffbuild_unconfigure() {
    echo --disable-zlib
}
