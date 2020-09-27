#!/bin/bash

LIBXML2_REPO="https://gitlab.gnome.org/GNOME/libxml2.git"
LIBXML2_COMMIT="7929f05710134b9b243952019b6c14066cd3ac9e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBXML2_REPO" "$LIBXML2_COMMIT" libxml2
    cd libxml2

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-maintainer-mode
        --disable-shared
        --enable-static
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
    make -j$(nproc) || return -1
    make install || return -1

    cd ..
    rm -rf libxml2
}

ffbuild_configure() {
    echo --enable-libxml2
}

ffbuild_unconfigure() {
    echo --disable-libxml2
}
