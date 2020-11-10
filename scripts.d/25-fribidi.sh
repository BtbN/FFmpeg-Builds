#!/bin/bash

FRIBIDI_REPO="https://github.com/fribidi/fribidi.git"
FRIBIDI_COMMIT="3585a81e625e5b35962bed11fdc99d54485048e0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$FRIBIDI_REPO" "$FRIBIDI_COMMIT" fribidi
    cd fribidi

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

    ./autogen.sh "${myconf[@]}" || return -1
    make || return -1
    make install || return -1

    sed -i 's/Cflags:/Cflags: -DFRIBIDI_LIB_STATIC/' "$FFBUILD_PREFIX"/lib/pkgconfig/fribidi.pc || return -1

    cd ..
    rm -rf fribidi
}

ffbuild_configure() {
    echo --enable-libfribidi
}

ffbuild_unconfigure() {
    echo --disable-libfribidi
}
