#!/bin/bash

MFX_REPO="https://github.com/lu-zero/mfx_dispatch.git"
MFX_COMMIT="2cd279f1e8a277c843025c8713c6ed3b4c42b032"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$MFX_REPO" "$MFX_COMMIT" mfx
    cd mfx

    autoreconf -i || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ..
    rm -rf mfx
}

ffbuild_configure() {
    echo --enable-libmfx
}

ffbuild_unconfigure() {
    echo --disable-libmfx
}
