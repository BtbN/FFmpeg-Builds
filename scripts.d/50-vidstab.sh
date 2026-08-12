#!/bin/bash

SCRIPT_REPO="https://github.com/georgmartius/vid.stab.git"
SCRIPT_COMMIT="c9985e75303da2ba1a78b37083a2bec2ed5baebc"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
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
    make install DESTDIR="$FFBUILD_DESTDIR"

    if [[ $TARGET == linux* ]]; then
        echo "Libs.private: -ldl" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/vidstab.pc
    fi
}

ffbuild_configure() {
    echo --enable-libvidstab
}

ffbuild_unconfigure() {
    echo --disable-libvidstab
}
