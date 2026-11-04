#!/bin/bash

SCRIPT_REPO="https://git.code.sf.net/p/soxr/code"
SCRIPT_COMMIT="945b592b70470e29f917f4de89b4281fbbd540c0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    sed -i 's/VERSION 3.1 /VERSION 3.1...3.10 /g' CMakeLists.txt

    # Short-circuit the check to generate a .pc file. We always want it.
    sed -i 's/NOT WIN32/1/g' src/CMakeLists.txt

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DWITH_OPENMP="$([[ $TARGET == winarm64 ]] && echo OFF || echo ON)" \
        -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=OFF \
        ..
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"

    if [[ $TARGET != winarm64 ]]; then
        echo "Libs.private: -lgomp" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/soxr.pc
    fi

    if [[ $TARGET == linuxriscv64 ]]; then
        # The static RISC-V libgomp archive contains versioned OpenMP aliases.
        # Define their nodes when linking it into FFmpeg's shared libraries.
        "$NM" -g --defined-only "$("$CC" -print-file-name=libgomp.a)" |
            sed -n 's/.*@\([^@ ]*\)$/\1/p' | sort -u | sed 's/$/ {};/' \
            > "$FFBUILD_DESTPREFIX"/lib/libgomp-versions.map
    fi
}

ffbuild_configure() {
    echo --enable-libsoxr
}

ffbuild_unconfigure() {
    echo --disable-libsoxr
}

ffbuild_ldflags() {
    echo -pthread
    if [[ $TARGET == linuxriscv64 ]]; then
        echo '-Wl,--exclude-libs,libgomp.a -Wl,--version-script=$FFBUILD_PREFIX/lib/libgomp-versions.map'
    fi
}

ffbuild_libs() {
    [[ $TARGET != winarm64 ]] && echo -lgomp
}
