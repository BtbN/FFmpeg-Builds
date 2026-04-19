#!/bin/bash

SCRIPT_REPO="https://github.com/oneapi-src/level-zero.git"
SCRIPT_COMMIT="b8d1a5624c38b04120d1665c1cf9e9373a5951ec"

#ffbuild_depends() {
#    echo zlib
#}

ffbuild_enabled() {
    # Probably just x86_64 i guess
    [[ $TARGET == android* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build
    export CXXFLAGS="$CXXFLAGS -Wno-error=strict-aliasing"

    # Configure the build. We disable shared libraries to keep the
    # resulting package small and static where possible.
    cmake -G Ninja \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_STATIC=1 \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DZLIB_INCLUDE_DIR="$FFBUILD_PREFIX/include" \
        ..

    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    echo "📦 Bundling Intel SYCL and Level Zero dynamic libraries..."

    export BUNDLE_DIR="$FFBUILD_DESTPREFIX/level-zero/"
    mkdir -p "$BUNDLE_DIR"

    cp -a /opt/intel/oneapi/compiler/latest/lib/libsycl.so* "$BUNDLE_DIR"
    cp -a /opt/intel/oneapi/compiler/latest/lib/libur_loader.so* "$BUNDLE_DIR"
    cp -a /opt/intel/oneapi/compiler/latest/lib/libsvml.so* "$BUNDLE_DIR"
    cp -a /opt/intel/oneapi/compiler/latest/lib/libintlc.so* "$BUNDLE_DIR"
    cp -a /opt/intel/oneapi/compiler/latest/lib/libirng.so* "$BUNDLE_DIR"
    cp -a /opt/intel/oneapi/compiler/latest/lib/libirc.so* "$BUNDLE_DIR"
    cp -a /opt/intel/oneapi/compiler/latest/lib/libimf.so* "$BUNDLE_DIR"
    cp -a /usr/lib/x86_64-linux-gnu/libz.so* "$BUNDLE_DIR"

    # cp -a "${FFBUILD_DESTPREFIX}"/lib/libze_loader.so* "$BUNDLE_LIB_DIR/"

    echo "✅ Dynamic libraries bundled successfully!"

    sed -i 's/Libs.private:/Libs.private: -lstdc++/; t; $ a Libs.private: -lstdc++' "$FFBUILD_DESTPREFIX"/lib/pkgconfig/libze_loader.pc
}

ffbuild_ldflags() {
# 1. Ignore missing transitive shared library symbols (Fixes the zlib/crc32 error instantly!)
echo "-Wl,--allow-shlib-undefined"

# 2. Add Intel's library directory so the cross-linker can find libsycl.so
# echo "-Wl,-rpath-link=/opt/intel/oneapi/compiler/latest/lib"
# echo "-L/opt/intel/oneapi/compiler/latest/lib"
}

# ffbuild_libs() {
    # echo -lz
# }

# ffbuild_configure() {
#     echo --enable-libvmaf-sycl
# }

# ffbuild_unconfigure() {
#     echo --disable-libvmaf-sycl
# }
