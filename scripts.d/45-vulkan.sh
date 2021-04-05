#!/bin/bash

LOADER_REPO="https://github.com/KhronosGroup/Vulkan-Loader.git"
LOADER_COMMIT="7ea01c139ffc7c33cd12bd258c1bc8bf530c6d2d"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "ADD patches/vulkan /stage/patches"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git clone "$LOADER_REPO" loader
    git -C loader checkout "$LOADER_COMMIT"

    for patch in patches/*.patch; do
        echo "Applying $patch"
        git -C loader am -3 < "$patch"
    done

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

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_TESTS=OFF -DBUILD_STATIC_LOADER=ON ..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-vulkan
}

ffbuild_unconfigure() {
    echo --disable-vulkan
}
