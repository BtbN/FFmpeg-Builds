#!/bin/bash

HARFBUZZ_REPO="https://github.com/harfbuzz/harfbuzz.git"
HARFBUZZ_COMMIT="faf09f5466370a45e1a9d7c07968af517d680d78"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /root/harfbuzz.sh"
    to_df "RUN bash -c 'source /root/harfbuzz.sh && ffbuild_dockerbuild && rm /root/harfbuzz.sh'"
}

ffbuild_dockerbuild() {
    git clone "$HARFBUZZ_REPO" harfbuzz || return -1
    cd harfbuzz
    git checkout "$HARFBUZZ_COMMIT" || return -1

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

    export LIBS="-lpthread"

    ./autogen.sh "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ..
    rm -rf harfbuzz
}
