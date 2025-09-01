#!/bin/bash

SCRIPT_REPO="https://github.com/ggml-org/whisper.cpp.git"
SCRIPT_COMMIT="5527454cdb3e15d7e2b8a6e2afcb58cb61651fd2"

ffbuild_depends() {
    echo base
    echo vulkan
    echo opencl
}

ffbuild_enabled() {
    [[ $TARGET != *32 ]] || return -1
    (( $(ffbuild_ffver) >= 800 )) || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF -DWHISPER_BUILD_TESTS=OFF -DWHISPER_BUILD_EXAMPLES=OFF -DWHISPER_BUILD_SERVER=OFF -DWHISPER_USE_SYSTEM_GGML=OFF \
        -DGGML_CCACHE=OFF -DGGML_OPENCL=ON -DGGML_VULKAN=ON \
        -DGGML_NATIVE=OFF -DGGML_SSE42=ON -DGGML_AVX=ON -DGGML_F16C=ON -DGGML_AVX2=ON -DGGML_BMI2=ON -DGGML_FMA=ON ..

    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    # For some reason, these lack the lib prefix on Windows
    shopt -s nullglob
    for libfile in "$FFBUILD_DESTPREFIX"/lib/ggml*.a; do
        mv "${libfile}" "$(dirname "${libfile}")/lib$(basename "${libfile}")"
    done

    # Linking order is all wrong
    sed -i -e 's/^\(Libs:\).*$/\1 -L${libdir} -lwhisper/' "$FFBUILD_DESTPREFIX"/lib/pkgconfig/whisper.pc
    echo "Libs.private: -lggml -lggml-base -lggml-cpu -lggml-vulkan -lggml-opencl -lstdc++" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/whisper.pc
    echo "Requires: vulkan OpenCL" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/whisper.pc
}

ffbuild_configure() {
    echo --enable-whisper
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) >= 800 )) || return 0
    echo --disable-whisper
}
