#!/bin/bash

RAV1E_REPO="https://github.com/xiph/rav1e.git"
RAV1E_COMMIT="df8b712b068826ee7fec04bb0b5829289fd4c6fa"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
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
