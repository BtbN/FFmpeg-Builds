#!/bin/bash

SCRIPT_REPO="https://github.com/AcademySoftwareFoundation/openapv.git"
SCRIPT_COMMIT="83218879aec34a31ebd4c17626ab02a5c6860652"

ffbuild_enabled() {
    (( $(ffbuild_ffver) > 701 )) || return -1
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo "git fetch --unshallow --filter=blob:none"
}

ffbuild_dockerbuild() {
    # No need to build this
    echo > app/CMakeLists.txt

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DCMAKE_BUILD_TYPE=Release \
        -DOAPV_APP_STATIC_BUILD=ON -DENABLE_TESTS=OFF ..

    make -j$(nproc)
    make install

    mv "$FFBUILD_PREFIX"/lib{/oapv/liboapv.a,}
    rm -rf "$FFBUILD_PREFIX"/{bin,lib/oapv,include/oapv/oapv_exports.h,lib/liboapv.so*}

    {
        echo "Libs.private: -lm"
        echo "Cflags.private: -DOAPV_STATIC_DEFINE"
    } >> "$FFBUILD_PREFIX"/lib/pkgconfig/oapv.pc
}

ffbuild_configure() {
    echo --enable-liboapv
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) > 701 )) || return 0
    echo --disable-liboapv
}
