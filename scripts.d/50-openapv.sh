#!/bin/bash

SCRIPT_REPO="https://github.com/AcademySoftwareFoundation/openapv.git"
SCRIPT_COMMIT="d625af974550427e638574db61c270fe7f8c5a73"

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

    if [[ $TARGET == *32 ]]; then
        export CFLAGS="$CFLAGS -msse -msse2"
        export CXXFLAGS="$CXXFLAGS -msse -msse2"
    fi

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DCMAKE_BUILD_TYPE=Release \
        -DOAPV_APP_STATIC_BUILD=ON -DENABLE_TESTS=OFF ..

    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"

    rm -rf "$FFBUILD_DESTPREFIX"/{bin,lib/oapv,lib/import,include/oapv/oapv_exports.h,lib/liboapv.so*}

    {
        echo "Libs.private: -lm"
        echo "Cflags.private: -DOAPV_STATIC_DEFINE"
    } >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/oapv.pc

    printf '\n%s\n%s\n%s\n%s\n' \
        '#ifndef OLD_APV_API_MACRO' \
        '#define OLD_APV_API_MACRO' \
        '#define oapvm_create(err) oapvm_create(&(oapvm_cdesc_t){ 0 }, (err))' \
        '#endif' >> "$FFBUILD_DESTPREFIX"/include/oapv/oapv.h
}

ffbuild_configure() {
    echo --enable-liboapv
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) > 701 )) || return 0
    echo --disable-liboapv
}
