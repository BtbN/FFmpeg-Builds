#!/bin/bash

SCRIPT_REPO="https://github.com/oneapi-src/oneVPL.git"
SCRIPT_COMMIT="fcabffb463299a8792c6baed69afbb69236ba6cb"

ffbuild_enabled() {
    [[ $TARGET == *arm64 ]] && return -1
    [[ $ADDINS_STR == *4.4* ]] && return -1
    [[ $ADDINS_STR == *5.0* ]] && return -1
    [[ $ADDINS_STR == *5.1* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" onevpl
    cd onevpl

    mkdir build && cd build

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_INSTALL_BINDIR="$FFBUILD_PREFIX"/bin -DCMAKE_INSTALL_LIBDIR="$FFBUILD_PREFIX"/lib \
        -DBUILD_DISPATCHER=ON -DBUILD_DEV=ON \
        -DBUILD_PREVIEW=OFF -DBUILD_TOOLS=OFF -DBUILD_TOOLS_ONEVPL_EXPERIMENTAL=OFF -DINSTALL_EXAMPLE_CODE=OFF \
        -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTS=OFF ..

    ninja -j$(nproc)
    ninja install

    rm -rf "$FFBUILD_PREFIX"/{etc,share}
}

ffbuild_configure() {
    echo --enable-libvpl
}

ffbuild_unconfigure() {
    [[ $ADDINS_STR == *4.4* ]] && return 0
    [[ $ADDINS_STR == *5.0* ]] && return 0
    [[ $ADDINS_STR == *5.1* ]] && return 0

    echo --disable-libvpl
}
