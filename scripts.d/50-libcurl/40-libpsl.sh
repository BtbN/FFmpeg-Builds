#!/bin/bash

SCRIPT_REPO="https://github.com/rockdaboot/libpsl.git"
SCRIPT_COMMIT="620d51d13351e8f3cb724471032246592c9bbd69"

SCRIPT_REPO2="https://github.com/publicsuffix/list.git"
SCRIPT_COMMIT2="8437e5262f13305f94087abe699b4fe2be1d1de8"

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
