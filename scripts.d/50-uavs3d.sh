#!/bin/bash

SCRIPT_REPO="https://github.com/uavs3/uavs3d.git"
SCRIPT_COMMIT="1fd04917cff50fac72ae23e45f82ca6fd9130bd8"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    [[ $TARGET == winarm64 ]] && return -1
    return 0
}

ffbuild_dockerdl() {
    echo "git clone \"$SCRIPT_REPO\" . && git checkout \"$SCRIPT_COMMIT\""
}

ffbuild_dockerbuild() {
    mkdir -p build/linux
    cd build/linux

    build_cmake -DCOMPILE_10BIT=1 -DBUILD_SHARED_LIBS=NO ../..
}

ffbuild_configure() {
    echo $(ffbuild_enable libuavs3d)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libuavs3d)
}
