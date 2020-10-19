#!/bin/bash

DAVS2_REPO="https://github.com/pkuvcl/davs2.git"
DAVS2_COMMIT="b06d7585620f4e90a6d19a2926bb4e59793b8942"

ffbuild_enabled() {
    [[ $VARIANT == gpl* ]] || return -1
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git clone "$DAVS2_REPO" davs2
    cd davs2
    git checkout "$DAVS2_COMMIT"
    cd build/linux

    local myconf=(
        --disable-cli
        --enable-pic
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
            --cross-prefix="$FFBUILD_CROSS_PREFIX"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ../../..
    rm -rf davs2
}

ffbuild_configure() {
    echo --enable-libdavs2
}

ffbuild_unconfigure() {
    echo --disable-libdavs2
}
