#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/rav1e.git"
SCRIPT_COMMIT="38879ab5a5b1587264ae2cbba9df43dc9157da2d"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    local myconf=(
        --prefix="${FFBUILD_PREFIX}"
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

    export "AR_${FFBUILD_RUST_TARGET//-/_}"="${AR}"
    export "RANLIB_${FFBUILD_RUST_TARGET//-/_}"="${RANLIB}"
    export "NM_${FFBUILD_RUST_TARGET//-/_}"="${NM}"
    export "LD_${FFBUILD_RUST_TARGET//-/_}"="${LD}"
    export "CC_${FFBUILD_RUST_TARGET//-/_}"="${CC}"
    export "CXX_${FFBUILD_RUST_TARGET//-/_}"="${CXX}"
    export "LD_${FFBUILD_RUST_TARGET//-/_}"="${LD}"
    export "CFLAGS_${FFBUILD_RUST_TARGET//-/_}"="${CFLAGS}"
    export "CXXFLAGS_${FFBUILD_RUST_TARGET//-/_}"="${CXXFLAGS}"
    export "LDFLAGS_${FFBUILD_RUST_TARGET//-/_}"="${LDFLAGS}"
    unset AR RANLIB NM CC CXX LD CFLAGS CXXFLAGS LDFLAGS

    cargo cinstall -v "${myconf[@]}"

    chmod 644 "${FFBUILD_PREFIX}"/lib/*rav1e*
}

ffbuild_configure() {
    echo --enable-librav1e
}

ffbuild_unconfigure() {
    echo --disable-librav1e
}
