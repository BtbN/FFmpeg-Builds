#!/bin/bash

HARFBUZZ_REPO="https://github.com/harfbuzz/harfbuzz.git"
HARFBUZZ_COMMIT="5539d158b75470dcf41bb86e2e8b9a7a986447c0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$HARFBUZZ_REPO" "$HARFBUZZ_COMMIT" harfbuzz
    cd harfbuzz

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
