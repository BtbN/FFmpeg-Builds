#!/bin/bash

SCRIPT_REPO="https://github.com/zeromq/libzmq.git"
SCRIPT_COMMIT="0ed7a08cd946e0832ac4655b7a76c09ac221f63b"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN"
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX"
        -DBUILD_SHARED=OFF
        -DBUILD_STATIC=ON
        -DBUILD_TESTS=OFF
        -DENABLE_INTRINSICS=ON
        -DENABLE_DRAFTS=OFF
        -DWITH_TLS=OFF
        -DWITH_DOCS=OFF
        -DENABLE_CPACK=OFF
        -DENABLE_NO_EXPORT=ON
    )

    if [[ $TARGET == win* ]]; then
        myconf+=( -DPOLLER="epoll" )
    fi

    cmake "${myconf[@]}" ..
    make -j$(nproc)
    make install

    {
        echo "Cflags.private: -DZMQ_NO_EXPORT -DZMQ_STATIC"
        [[ $TARGET != win* ]] || echo "Libs.private: -lws2_32 -liphlpapi"
    } >> "$FFBUILD_PREFIX"/lib/pkgconfig/libzmq.pc
}

ffbuild_configure() {
    echo --enable-libzmq
}

ffbuild_unconfigure() {
    echo --disable-libzmq
}
