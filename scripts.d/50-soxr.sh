#!/bin/bash

SCRIPT_REPO="https://git.code.sf.net/p/soxr/code"
SCRIPT_COMMIT="945b592b70470e29f917f4de89b4281fbbd540c0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    # Short-circuit the check to generate a .pc file. We always want it.
    sed -i 's/NOT WIN32/1/g' src/CMakeLists.txt

    build_cmake \
        -DWITH_OPENMP="$([[ $TARGET == winarm64 ]] && echo OFF || echo ON)" \
        -DBUILD_TESTS=OFF \
        -DBUILD_EXAMPLES=OFF

    if [[ $TARGET != winarm64 ]]; then
        add_pkgconfig_libs_private soxr gomp
    fi
}

ffbuild_configure() {
    echo $(ffbuild_enable libsoxr)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libsoxr)
}

ffbuild_ldflags() {
    echo -pthread
}

ffbuild_libs() {
    [[ $TARGET != winarm64 ]] && echo -lgomp
}
