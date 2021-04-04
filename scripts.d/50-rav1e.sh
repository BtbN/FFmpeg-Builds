#!/bin/bash

RAV1E_REPO="https://github.com/xiph/rav1e.git"
RAV1E_COMMIT="d6e4b5c714f107f9cc6991d44927fd029ba53a72"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$RAV1E_REPO" "$RAV1E_COMMIT" rav1e
    cd rav1e

    cargo cinstall \
        --target="$FFBUILD_RUST_TARGET" \
        --prefix="$FFBUILD_PREFIX" \
        --crt-static \
        --release

    rm "${FFBUILD_PREFIX}"/{lib/rav1e.dll.a,lib/rav1e.def,bin/rav1e.dll}

    cd ..
    rm -rf rav1e
}

ffbuild_configure() {
    echo --enable-librav1e
}

ffbuild_unconfigure() {
    [[ $VARIANT == *4.2* ]] && return 0
    echo --disable-librav1e
}
