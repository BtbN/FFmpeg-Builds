#!/bin/bash

SCRIPT_REPO="https://github.com/xqq/libaribcaption"
SCRIPT_COMMIT="0a3a209d3f0b3650b92941248b9701bf69584a1f"

ffbuild_enabled() {
    # since 6.1
    [[ $ADDINS_STR == *4.4* ]] && return -1
    [[ $ADDINS_STR == *5.0* ]] && return -1
    [[ $ADDINS_STR == *5.1* ]] && return -1
    [[ $ADDINS_STR == *6.0* ]] && return -1

    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" libaribcaption
    mkdir -p libaribcaption/build
    cd libaribcaption/build
    cmake .. -DCMAKE_BUILD_TYPE=Release -DARIBCC_USE_FREETYPE:BOOL=ON -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX"
    cmake --build . -j$(nproc)
    cmake --install .

    sed -i 's/Libs.private:/Libs.private: -lstdc++/; t; $ a Libs.private: -lstdc++' "$FFBUILD_PREFIX"/lib/pkgconfig/libaribcaption.pc
    if [[ $TARGET == win* ]]; then
        sed -i 's/Libs.private:/Libs.private: -lole32/; t; $ a Libs.private: -lole32' "$FFBUILD_PREFIX"/lib/pkgconfig/libaribcaption.pc
    fi
}

ffbuild_configure() {
    echo --enable-libaribcaption
}

ffbuild_unconfigure() {
    [[ $ADDINS_STR == *4.4* ]] && return
    [[ $ADDINS_STR == *5.0* ]] && return
    [[ $ADDINS_STR == *5.1* ]] && return
    [[ $ADDINS_STR == *6.0* ]] && return

    echo --disable-libaribcaption
}
