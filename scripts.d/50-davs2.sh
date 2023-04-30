#!/bin/bash

SCRIPT_REPO="https://github.com/pkuvcl/davs2.git"
SCRIPT_COMMIT="b41cf117452e2d73d827f02d3e30aa20f1c721ac"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $TARGET == win32 ]] && return -1
    return -1
}

ffbuild_dockerbuild() {
    git clone "$SCRIPT_REPO" davs2
    cd davs2
    git checkout "$SCRIPT_COMMIT"
    cd build/linux

    local myconf=(
        --disable-cli
        --enable-pic
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
            --cross-prefix="$FFBUILD_CROSS_PREFIX"
        )
    else
        echo "Unknown target"
        return -1
    fi

    # Work around configure endian check failing on modern gcc/binutils.
    # Assumes all supported archs are little endian.
    sed -i -e 's/EGIB/bss/g' -e 's/naidnePF/bss/g' configure

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libdavs2
}

ffbuild_unconfigure() {
    echo --disable-libdavs2
}
