#!/bin/bash
SCRIPT_REPO="https://github.com/Netflix/vmaf.git"
SCRIPT_COMMIT="44a92543264b096378ad11b82b458dcf23e8e5dd"

ffbuild_enabled() {
    return 0
}

ffbuild_depends() {
    echo base
    echo ffnvcodec
    if [[ "$ADDINS_STR" == *lusoris ]]; then
        echo level-zero
    fi
}

ffbuild_dockerstage() {
    to_df "RUN --mount=src=${SELF},dst=/stage.sh --mount=src=${SELFCACHE},dst=/cache.tar.xz --mount=src=patches/blackbeard,dst=/patches run_stage /stage.sh"
}

ffbuild_dockerbuild() {
    # Kill build of unused and broken tools
    echo >libvmaf/tools/meson.build

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Dbuilt_in_models=true
        -Denable_tests=false
        -Denable_docs=false
        -Denable_avx512=true
        -Denable_float=true
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    source /patches/blackbeard.sh
    meson "${myconf[@]}" ../libvmaf ../libvmaf/build || cat ../libvmaf/build/meson-logs/meson-log.txt
    ninja -j"$(nproc)" -C ../libvmaf/build
    DESTDIR="$FFBUILD_DESTDIR" ninja install -C ../libvmaf/build

    sed -i 's/Libs.private:/Libs.private: -lstdc++/; t; $ a Libs.private: -lstdc++' "$FFBUILD_DESTPREFIX"/lib/pkgconfig/libvmaf.pc
}

ffbuild_configure() {
    (($(ffbuild_ffver) >= 501)) || return 0
    echo --enable-libvmaf
}

ffbuild_unconfigure() {
    echo --disable-libvmaf
}
