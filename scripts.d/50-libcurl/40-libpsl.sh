#!/bin/bash

SCRIPT_REPO="https://github.com/rockdaboot/libpsl.git"
SCRIPT_COMMIT="a629c831d09011f76974d931be7f6167be90673e"

SCRIPT_REPO2="https://github.com/publicsuffix/list.git"
SCRIPT_COMMIT2="a179a48c465e818cfd8d626691cb317985da87fb"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo "git-mini-clone \"$SCRIPT_REPO2\" \"$SCRIPT_COMMIT2\" list"
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Druntime=no
        -Dbuiltin=true
        -Dtests=false
        -Ddocs=false
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson setup "${myconf[@]}" ..
    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install
}
