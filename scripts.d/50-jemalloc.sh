#!/bin/bash

SCRIPT_REPO="https://github.com/jemalloc/jemalloc.git"
SCRIPT_COMMIT="da66aa391f853ccf2300845b3873cc8f1cf48f2d"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    default_dl "$SELF"
    to_df "RUN git -C \"$SELF\" fetch --unshallow --filter=blob:none && git -C \"$SELF\" fetch --tags --filter=blob:none"
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR/$SELF"

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --with-jemalloc-prefix=je_
        --disable-shared
        --enable-static
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    echo "Libs.private: @LIBS@" >> jemalloc.pc.in
    echo "jemalloc_prefix=@JEMALLOC_PREFIX@" >> jemalloc.pc.in

    CFLAGS="${CFLAGS/-fPIC/}"
    CFLAGS="${CFLAGS/-DPIC/}"
    export CFLAGS="${CFLAGS/-fno-semantic-interposition/} -fPIE"
    CXXFLAGS="${CXXFLAGS/-fPIC/}"
    CXXFLAGS="${CXXFLAGS/-DPIC/}"
    export CXXFLAGS="${CXXFLAGS/-fno-semantic-interposition/} -fPIE"

    ./autogen.sh "${myconf[@]}"
    make -j$(nproc) build_lib_static
    make install_include install_lib_static install_lib_pc

    if [[ $VARIANT == *shared* ]]; then
        mv "$FFBUILD_PREFIX"/lib/libjemalloc{_pic,}.a
    else
        rm "$FFBUILD_PREFIX"/lib/libjemalloc_pic.a
    fi
}

ffbuild_configure() {
    echo --custom-allocator=jemalloc
}
