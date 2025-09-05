#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/opus.git"
SCRIPT_COMMIT="ddbe48383984d56acd9e1ab6a090c54ca6b735a6" # v1.5.2

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    default_dl .

    # This is where they decided to put downloads for external dependencies, so it needs to run here
    echo "./autogen.sh"
}

ffbuild_dockerbuild() {
    # re-run autoreconf explicitly because tools versions might have changed since it generared the dl cache
    autoreconf -isf

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --host="$FFBUILD_TOOLCHAIN"
        --disable-shared
        --enable-static
        --disable-extra-programs
    )

    if [[ $TARGET == winarm* ]]; then
        myconf+=(
            --disable-rtcd
        )
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-libopus
}

ffbuild_unconfigure() {
    echo --disable-libopus
}
