#!/bin/bash

HEADERS_REPO="https://github.com/KhronosGroup/OpenCL-Headers.git"
HEADERS_COMMIT="dcd5bede6859d26833cd85f0d6bbcee7382dc9b3"

LOADER_REPO="https://github.com/KhronosGroup/OpenCL-ICD-Loader.git"
LOADER_COMMIT="cd7d07cfa667d8d959b4272be45cf217a65c2948"

ffbuild_enabled() {
    return -1
}

ffbuild_dockerbuild() {
    mkdir opencl && cd opencl

    git-mini-clone "$HEADERS_REPO" "$HEADERS_COMMIT" headers
    mkdir -p "$FFBUILD_PREFIX"/include/CL
    cp -r headers/CL/* "$FFBUILD_PREFIX"/include/CL/.

    git-mini-clone "$LOADER_REPO" "$LOADER_COMMIT" loader
    cd loader

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DOPENCL_ICD_LOADER_HEADERS_DIR="$FFBUILD_PREFIX"/include -DOPENCL_ICD_LOADER_BUILD_SHARED_LIBS=OFF -DOPENCL_ICD_LOADER_DISABLE_OPENCLON12=ON -DOPENCL_ICD_LOADER_PIC=ON -DOPENCL_ICD_LOADER_BUILD_TESTING=OFF -DBUILD_TESTING=OFF ..
    make -j$(nproc)
    make install

    echo "prefix=$FFBUILD_PREFIX" > OpenCL.pc
    echo "exec_prefix=\${prefix}" >> OpenCL.pc
    echo "libdir=\${exec_prefix}/lib" >> OpenCL.pc
    echo "includedir=\${prefix}/include" >> OpenCL.pc
    echo >> OpenCL.pc
    echo "Name: OpenCL" >> OpenCL.pc
    echo "Description: OpenCL ICD Loader" >> OpenCL.pc
    echo "Version: 9999" >> OpenCL.pc
    echo "Libs: -L\${libdir} -lOpenCL" >> OpenCL.pc
    echo "Cflags: -I\${includedir}" >> OpenCL.pc

    if [[ $TARGET == linux* ]]; then
        echo "Libs.private: -ldl" >> OpenCL.pc
    elif [[ $TARGET == win* ]]; then
        echo "Libs.private: -lole32 -lshlwapi -lcfgmgr32" >> OpenCL.pc
    fi

    mkdir -p "$FFBUILD_PREFIX"/lib/pkgconfig
    mv OpenCL.pc "$FFBUILD_PREFIX"/lib/pkgconfig/OpenCL.pc
}

ffbuild_configure() {
    echo --enable-opencl
}

ffbuild_unconfigure() {
    echo --disable-opencl
}
