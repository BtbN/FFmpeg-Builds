#!/bin/bash

LOADER_REPO="https://github.com/BtbN/Vulkan-Loader.git"
LOADER_COMMIT="71b69578649bbed2696a21f063c0e3c15d36ce36"

ffbuild_enabled() {
    [[ $ADDINS_STR != *vulkan* ]] && return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    mkdir vulkan && cd vulkan

    git-mini-clone "$LOADER_REPO" "$LOADER_COMMIT" loader

    HEADERS_REPO="$(grep -A10 'name.*:.*Vulkan-Headers' loader/scripts/known_good.json | grep url | head -n1 | cut -d'"' -f4)"
    HEADERS_COMMIT="$(grep -A10 'name.*:.*Vulkan-Headers' loader/scripts/known_good.json | grep commit | head -n1 | cut -d'"' -f4)"

    git-mini-clone "$HEADERS_REPO" "$HEADERS_COMMIT" headers

    cd headers

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" ..
    make -j$(nproc)
    make install

    cd ../../loader

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_TESTS=OFF ..
    make -j$(nproc)
    make install

    cd ..
    rm -rf vulkan
}

ffbuild_configure() {
    echo --enable-vulkan
}

ffbuild_unconfigure() {
    echo --disable-vulkan
}
