#!/bin/bash

SCRIPT_REPO="https://git.savannah.gnu.org/git/libiconv.git"
SCRIPT_COMMIT="6e2b31f6d66739c5abd850338ea68c6bd2012812"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    to_df "RUN retry-tool sh -c \"rm -rf $SELF && git clone '$SCRIPT_REPO' $SELF\" && git -C $SELF checkout \"$SCRIPT_COMMIT\""
    to_df "RUN cd $SELF && retry-tool ./autopull.sh --one-time"
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR/$SELF"

    (unset CC CFLAGS GMAKE && ./autogen.sh)

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-extra-encodings
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
    echo --enable-iconv
}

ffbuild_unconfigure() {
    echo --disable-iconv
}
