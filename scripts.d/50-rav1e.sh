#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/rav1e.git"
SCRIPT_COMMIT="db7a71ae53a31a60bf31bd0635f46e15bdcc444c"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" rav1e
    cd rav1e

    local myconf=(
        --prefix="$FFBUILD_PREFIX" \
        --library-type=staticlib \
        --crt-static \
    )

    if [[ $TARGET == win_not_yet ]]; then
        # CHECKME: back to release once lto is fixed
        myconf+=(
            --profile release-no-lto
        )
    else
        myconf+=(
            --release
        )
    fi

    export CC="${FFBUILD_CROSS_PREFIX}gcc"
    export CXX="${FFBUILD_CROSS_PREFIX}g++"
    export LD="${FFBUILD_CROSS_PREFIX}gcc"
    export AR="${FFBUILD_CROSS_PREFIX}ar"

    if [[ -n "$FFBUILD_RUST_TARGET" ]]; then
        myconf+=(
            --target="$FFBUILD_RUST_TARGET"
        )
        cat <<EOF >$CARGO_HOME/config.toml
[build]
target = "$FFBUILD_RUST_TARGET"
[target.$FFBUILD_RUST_TARGET]
linker = "$LD"
ar = "$AR"
EOF
    fi

    cargo cinstall -v "${myconf[@]}"
}

ffbuild_configure() {
    echo --enable-librav1e
}

ffbuild_unconfigure() {
    echo --disable-librav1e
}
