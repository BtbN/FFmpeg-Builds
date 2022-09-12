#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/rav1e.git"
SCRIPT_COMMIT="25f6c0fadc51f65a0c05ca4540cb8699eba5c644"

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

    if [[ -n "$FFBUILD_RUST_TARGET" ]]; then
        unset PKG_CONFIG_LIBDIR

        myconf+=(
            --target="$FFBUILD_RUST_TARGET"
        )
        cat <<EOF >$CARGO_HOME/config.toml
[build]
target = "$FFBUILD_RUST_TARGET"
[target.$FFBUILD_RUST_TARGET]
linker = "${FFBUILD_CROSS_PREFIX}ld"
ar = "${FFBUILD_CROSS_PREFIX}ar"
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
