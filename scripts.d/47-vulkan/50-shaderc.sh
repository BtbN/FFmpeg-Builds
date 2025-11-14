#!/bin/bash

SCRIPT_REPO="https://github.com/google/shaderc.git"
SCRIPT_COMMIT="73743588fe9c39f2f1c780a087d94afac691a189"

ffbuild_enabled() {
    [[ $ADDINS_STR == *4.4* ]] && return -1
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo "./utils/git-sync-deps || exit $?"
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DSHADERC_SKIP_TESTS=ON -DSHADERC_SKIP_EXAMPLES=ON -DSHADERC_SKIP_COPYRIGHT_CHECK=ON \
        -DENABLE_EXCEPTIONS=ON -DENABLE_GLSLANG_BINARIES=OFF -DSPIRV_SKIP_EXECUTABLES=ON \
        -DSPIRV_TOOLS_BUILD_STATIC=ON -DBUILD_SHARED_LIBS=OFF ..
    ninja -j$(nproc)

    export DESTDIR="/tmp/staging$FFBUILD_DESTDIR"
    ninja install

    if [[ $TARGET == win* ]]; then
        rm -r "${DESTDIR}${FFBUILD_PREFIX}"/bin "${DESTDIR}${FFBUILD_PREFIX}"/lib/*.dll.a
    elif [[ $TARGET == linux* ]]; then
        rm -r "${DESTDIR}${FFBUILD_PREFIX}"/bin "${DESTDIR}${FFBUILD_PREFIX}"/lib/*.so*
    else
        echo "Unknown target"
        return -1
    fi

    cp -al "$DESTDIR"/. "$FFBUILD_DESTDIR"
    rm -rf "$DESTDIR"
    unset DESTDIR

    # for some reason, this does not get installed...
    cp libshaderc_util/libshaderc_util.a "$FFBUILD_DESTPREFIX"/lib

    echo "Libs: -lstdc++" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/shaderc_combined.pc
    echo "Libs: -lstdc++" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/shaderc_static.pc

    cp "$FFBUILD_DESTPREFIX"/lib/pkgconfig/{shaderc_combined,shaderc}.pc

    mkdir ../native_build && cd ../native_build

    unset CC CXX CFLAGS CXXFLAGS LD LDFLAGS AR RANLIB NM DLLTOOL PKG_CONFIG_LIBDIR
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release \
        -DSHADERC_SKIP_TESTS=ON -DSHADERC_SKIP_EXAMPLES=ON -DSHADERC_SKIP_COPYRIGHT_CHECK=ON \
        -DENABLE_EXCEPTIONS=ON -DSPIRV_TOOLS_BUILD_STATIC=ON -DBUILD_SHARED_LIBS=OFF ..
    ninja -j$(nproc) glslc/glslc

    cp glslc/glslc /opt/glslc
}

ffbuild_configure() {
    echo --enable-libshaderc
}

ffbuild_unconfigure() {
    [[ $ADDINS_STR == *4.4* ]] && return 0
    echo --disable-libshaderc
}
