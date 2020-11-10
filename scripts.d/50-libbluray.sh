#!/bin/bash

LIBBLURAY_REPO="https://code.videolan.org/videolan/libbluray.git"
LIBBLURAY_COMMIT="a798b0533f024d9168e37a8e72e5bdeeac4b7d30"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBBLURAY_REPO" "$LIBBLURAY_COMMIT" libbluray
    cd libbluray

    ./bootstrap || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --disable-doxygen-doc
        --disable-doxygen-dot
        --disable-doxygen-html
        --disable-doxygen-ps
        --disable-doxygen-pdf
        --disable-examples
        --disable-bdjava-jar
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    cd ..
    rm -rf libbluray
}

ffbuild_configure() {
    echo --enable-libbluray
}

ffbuild_unconfigure() {
    echo --disable-libbluray
}
