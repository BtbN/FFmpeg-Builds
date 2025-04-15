#!/bin/bash

SCRIPT_REPO="https://github.com/fraunhoferhhi/vvenc.git"
SCRIPT_COMMIT="ebce395254d9d7be7dc00cec7b49c7ed1d9eebec"

ffbuild_enabled() {
    [[ $TARGET != *32 ]] || return -1
    (( $(ffbuild_ffver) > 700 )) || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local armsimd=()
    if [[ $TARGET == *arm* ]]; then
        armsimd+=( -DVVENC_ENABLE_ARM_SIMD=ON )

        if [[ "$CC" != *clang* ]]; then
            export CFLAGS="$CFLAGS -fpermissive -Wno-error=uninitialized -Wno-error=maybe-uninitialized"
            export CXXFLAGS="$CXXFLAGS -fpermissive -Wno-error=uninitialized -Wno-error=maybe-uninitialized"
        else
            export CFLAGS="$CFLAGS -Wno-error=deprecated-literal-operator"
            export CXXFLAGS="$CXXFLAGS -Wno-error=deprecated-literal-operator"
        fi
    fi

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF -DVVENC_LIBRARY_ONLY=ON -DVVENC_ENABLE_LINK_TIME_OPT=OFF -DEXTRALIBS="-lstdc++" "${armsimd[@]}" ..

    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libvvenc
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) > 700 )) || return 0
    echo --disable-libvvenc
}
