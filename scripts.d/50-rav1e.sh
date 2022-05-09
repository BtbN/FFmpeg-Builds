#!/bin/bash

RAV1E_REPO="https://github.com/xiph/rav1e.git"
RAV1E_COMMIT="a8d1e46e0dba460345e70a519d3becd079bb3acd"

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

    # For some reason, RUSTFLAGS, CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER,
    # and .cargo/config.toml can't work, so have to put a symbolic link
    if [[ $TARGET == linuxarm64 ]]; then
        ln -s /opt/ct-ng/bin/aarch64-ffbuild-linux-gnu-gcc /opt/ct-ng/bin/aarch64-linux-gnu-gcc
    fi

    cargo cinstall "${myconf[@]}"
}

ffbuild_configure() {
    echo --enable-librav1e
}

ffbuild_unconfigure() {
    echo --disable-librav1e
}
