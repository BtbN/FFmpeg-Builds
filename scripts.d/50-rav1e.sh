#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/rav1e.git"
SCRIPT_COMMIT="62b4888672aa5c1c8084a8114f999c0699e08080"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --target="${FFBUILD_RUST_TARGET}"
        --library-type=staticlib
        --crt-static
        --release
    )

    # Pulls in target-libs for host tool builds otherwise.
    # Luckily no target libraries are needed.
    unset PKG_CONFIG_LIBDIR

    # The pinned version is broken, and upstream does not react
    cargo update cc

    cargo cinstall -v "${myconf[@]}"

    chmod 644 "${FFBUILD_PREFIX}"/lib/*rav1e*
}

ffbuild_configure() {
    echo --enable-librav1e
}

ffbuild_unconfigure() {
    echo --disable-librav1e
}
