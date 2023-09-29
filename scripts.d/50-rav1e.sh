#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/rav1e.git"
SCRIPT_COMMIT="f8b95d97517a6e223f1c6a90a467188586dd090f"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR/$SELF"

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --library-type=staticlib
        --crt-static
        --release
    )

    if [[ -n "$FFBUILD_RUST_TARGET" ]]; then
        unset PKG_CONFIG_LIBDIR

        export CC="gcc"
        export CXX="g++"
        export TARGET_CC="${FFBUILD_CROSS_PREFIX}gcc"
        export TARGET_CXX="${FFBUILD_CROSS_PREFIX}g++"
        export CROSS_COMPILE=1
        export TARGET_CFLAGS="$CFLAGS"
        export TARGET_CXXFLAGS="$CFLAGS"
        unset CFLAGS
        unset CXXFLAGS

        myconf+=(
            --target="$FFBUILD_RUST_TARGET"
        )
        cat <<EOF >$CARGO_HOME/config.toml
[target.$FFBUILD_RUST_TARGET]
linker = "${FFBUILD_CROSS_PREFIX}gcc"
ar = "${FFBUILD_CROSS_PREFIX}ar"
EOF
    fi

    cargo cinstall -v "${myconf[@]}"

    chmod 644 "${FFBUILD_PREFIX}"/lib/*rav1e*
}

ffbuild_configure() {
    echo --enable-librav1e
}

ffbuild_unconfigure() {
    echo --disable-librav1e
}
