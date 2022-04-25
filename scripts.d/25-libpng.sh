#!/bin/bash

LIBPNG_REPO="https://github.com/glennrp/libpng.git"
LIBPNG_COMMIT="c17d164b4467f099b4484dfd4a279da0bc1dbd4a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "RUN --mount=src=${SELF},dst=/stage.sh --mount=src=patches/libpng,dst=/patches run_stage /stage.sh"
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBPNG_REPO" "$LIBPNG_COMMIT" libpng 
    cd libpng

    for patch in /patches/*.patch; do
        echo "Applying $patch"
        git am < "$patch"
    done

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
