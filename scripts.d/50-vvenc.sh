#!/bin/bash

SCRIPT_REPO="https://github.com/fraunhoferhhi/vvenc.git"
SCRIPT_COMMIT="667bb8ca34f50e22aae3b8a74f19be9547e4742f"

ffbuild_enabled() {
    [[ $TARGET != *32 ]] || return -1
    (( $(ffbuild_ffver) > 700 )) || return -1
    return 0
}

ffbuild_dockerbuild() {
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

    build_cmake \
        -DVVENC_LIBRARY_ONLY=ON \
        -DVVENC_ENABLE_WERROR=OFF \
        -DVVENC_ENABLE_LINK_TIME_OPT=OFF \
        -DEXTRALIBS="-lstdc++" \
        "${armsimd[@]}"
}

ffbuild_configure() {
    echo $(ffbuild_enable libvvenc)
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) > 700 )) || return 0
    echo $(ffbuild_disable libvvenc)
}
