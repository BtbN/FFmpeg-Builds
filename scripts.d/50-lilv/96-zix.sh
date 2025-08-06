#!/bin/bash

SCRIPT_REPO="https://github.com/drobilla/zix.git"
SCRIPT_COMMIT="a970ac9c1fa1341b83f2b1a4a1740590ec2cbfe7"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Ddocs=disabled
        -Dbenchmarks=disabled
        -Dtests=disabled
        -Dtests_cpp=disabled
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install
}
