#!/bin/bash

VMAF_REPO="https://github.com/Netflix/vmaf.git"
VMAF_COMMIT="9e1fb0bbc218855dc695166d77aea0a14e6d3527"

ffbuild_enabled() {
    return -1
}

ffbuild_dockerbuild() {
    git-mini-clone "$VMAF_REPO" "$VMAF_COMMIT" vmaf
    cd vmaf

    # Kill build of unused and broken tools
    echo > libvmaf/tools/meson.build

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

    meson "${myconf[@]}" ../libvmaf
    ninja -j"$(nproc)"
    ninja install

    sed -i 's/Libs.private:/Libs.private: -lstdc++/; t; $ a Libs.private: -lstdc++' "$FFBUILD_PREFIX"/lib/pkgconfig/libvmaf.pc
}

ffbuild_configure() {
    echo --enable-libvmaf
}

ffbuild_unconfigure() {
    echo --disable-libvmaf
}
