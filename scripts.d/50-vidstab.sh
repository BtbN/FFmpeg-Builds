#!/bin/bash

VIDSTAB_REPO="https://github.com/georgmartius/vid.stab.git"
# TODO: clamp to e7715fc until georgmartius/vid.stab#104 get fixed
VIDSTAB_COMMIT="e7715fcf329573cdcff5c57d0e4a25f4c3a0cb7f"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$VIDSTAB_REPO" "$VIDSTAB_COMMIT" vidstab
    cd vidstab

    mkdir build && cd build

    local mycmake=(
        -DBUILD_SHARED_LIBS=OFF
        -DUSE_OMP=ON
    )

    if [[ $TARGET == *arm64 ]]; then
        mycmake+=(
            -DSSE2_FOUND=FALSE
        )
    fi

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" "${mycmake[@]}" ..
    make -j$(nproc)
    make install

    if [[ $TARGET == linux* ]]; then
        echo "Libs.private: -ldl" >> "$FFBUILD_PREFIX"/lib/pkgconfig/vidstab.pc
    fi
}

ffbuild_configure() {
    echo --enable-libvidstab
}

ffbuild_unconfigure() {
    echo --disable-libvidstab
}
