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
ffbuild_dockerdl() {
    default_dl "$SELF"
}
ffbuild_dockerbuild() {
    mkdir -p "$FFBUILD_DLDIR/$SELF"/build
    cd "$FFBUILD_DLDIR/$SELF"/build
    cmake .. -DCMAKE_BUILD_TYPE=Release -DARIBCC_USE_FREETYPE:BOOL=ON -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX"
    make -j$(nproc)
    make install
    echo "Libs.private: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libaribcaption.pc
    if [[ $TARGET == win* ]]; then
    # Dirty hack: Delete `-l/opt/ct-ng/x86_64-w64-mingw32/lib/libstdc++.a` from libaribcaption.pc from  `Libs:`
        sed -i '/^Libs:/ s/-l\/opt\/ct-ng\/x86_64-w64-mingw32\/lib\/libstdc++.a//' "$FFBUILD_PREFIX"/lib/pkgconfig/libaribcaption.pc
    fi
}

ffbuild_configure() {
    echo --enable-libaribcaption
}

ffbuild_unconfigure() {
    [[ $ADDINS_STR == *4.4* ]] && return 0
    [[ $ADDINS_STR == *5.0* ]] && return 0
    [[ $ADDINS_STR == *5.1* ]] && return 0
    [[ $ADDINS_STR == *6.0* ]] && return 0

    echo --disable-libaribcaption
}
