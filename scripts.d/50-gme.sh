#!/bin/bash

SCRIPT_REPO="https://github.com/libgme/game-music-emu.git"
SCRIPT_COMMIT="bd7b3604dee43084aae0a2b4457ba7bf48554030"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    build_cmake -DCMAKE_DISABLE_FIND_PACKAGE_SDL2=1 -DENABLE_UBSAN=OFF
}

ffbuild_configure() {
    echo $(ffbuild_enable libgme)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libgme)
}
