#!/bin/bash

RAV1E_REPO="https://github.com/xiph/rav1e.git"
RAV1E_COMMIT="4c863c575420d900618b25cd75f2e52253cecf30"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return -1
}

ffbuild_dockerbuild() {
    git-mini-clone "$RAV1E_REPO" "$RAV1E_COMMIT" rav1e
    cd rav1e

    local myconf=(
        --prefix="$FFBUILD_PREFIX" \
        --library-type=staticlib \
        --crt-static \
        --release
    )

    if [[ -n "$FFBUILD_RUST_TARGET" ]]; then
        myconf+=(
            --target="$FFBUILD_RUST_TARGET"
        )
    fi

    cargo cinstall "${myconf[@]}"
}

ffbuild_configure() {
    echo --enable-librav1e
}

ffbuild_unconfigure() {
    echo --disable-librav1e
}
