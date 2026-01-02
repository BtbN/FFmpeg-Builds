#!/bin/bash

SCRIPT_REPO="https://github.com/intel/libvpl.git"
SCRIPT_COMMIT="778a66d6c6537f08eabb91955dbbf1bce3812894"

ffbuild_enabled() {
    [[ $TARGET == *arm64 ]] && return -1
    (( $(ffbuild_ffver) >= 600 )) || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_INSTALL_BINDIR="$FFBUILD_PREFIX"/bin -DCMAKE_INSTALL_LIBDIR="$FFBUILD_PREFIX"/lib \
        -DBUILD_DISPATCHER=ON -DBUILD_DEV=ON \
        -DBUILD_PREVIEW=OFF -DBUILD_TOOLS=OFF -DBUILD_TOOLS_ONEVPL_EXPERIMENTAL=OFF -DINSTALL_EXAMPLE_CODE=OFF \
        -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTS=OFF ..

    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    rm -rf "$FFBUILD_DESTPREFIX"/{etc,share}

    echo "Libs.private: -lstdc++" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/vpl.pc
}

ffbuild_configure() {
    echo --enable-libvpl
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) >= 600 )) || return 0
    echo --disable-libvpl
}
