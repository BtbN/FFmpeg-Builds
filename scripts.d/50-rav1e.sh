#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/rav1e.git"
SCRIPT_COMMIT="1412bed6b9cd54a46096b8aaf33557e5b740e4f8"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --library-type=staticlib
        --crt-static
        --release
    )

    if [[ -n "$FFBUILD_RUST_TARGET" ]]; then
        unset PKG_CONFIG_LIBDIR
        export CROSS_COMPILE=1

        export TARGET_CC="$CC"
        export TARGET_CXX="$CXX"
        export TARGET_CFLAGS="$CFLAGS"
        export TARGET_CXXFLAGS="$CXXFLAGS"
        unset CFLAGS
        unset CXXFLAGS
        export CC="gcc"
        export CXX="g++"

        myconf+=(
            --target="${FFBUILD_RUST_TARGET}"
            --config="target.${FFBUILD_RUST_TARGET}.linker=\"${TARGET_CC}\""
            --config="target.${FFBUILD_RUST_TARGET}.ar=\"${AR}\""
            # This is a horrible hack to work around cargo being too stupid for cross-builds to the same target.
            # When building for Linux, it will try to build a build-time tool with the target-linker, which fails horribly.
            # Since we are only creating a static lib, the linker is never actually used. So just always force it to host gcc.
            --config="target.x86_64-unknown-linux-gnu.linker=\"gcc\""
        )
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
