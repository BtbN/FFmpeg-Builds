#!/bin/bash

SCRIPT_REPO="https://github.com/nkoriyama/aribb24.git"
SCRIPT_COMMIT="5e9be272f96e00f15a2f3c5f8ba7e124862aec38"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "RUN --mount=src=${SELF},dst=/stage.sh --mount=src=/,dst=\$FFBUILD_DLDIR,from=${DL_IMAGE},rw --mount=src=patches/aribb24,dst=/patches run_stage /stage.sh"
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR/$SELF"

    for patch in /patches/*.patch; do
        echo "Applying $patch"
        git am < "$patch"
    done

    # Library switched to LGPL on master, but didn't bump version since.
    # FFmpeg checks for >1.0.3 to allow LGPL builds.
    sed -i 's/1.0.3/1.0.4/' configure.ac

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
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
}

ffbuild_configure() {
    echo --enable-libaribb24
}

ffbuild_unconfigure() {
    echo --disable-libaribb24
}
