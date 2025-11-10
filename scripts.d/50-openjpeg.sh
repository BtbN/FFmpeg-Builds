#!/bin/bash

SCRIPT_REPO="https://github.com/uclouvain/openjpeg.git"
SCRIPT_COMMIT="1ad9bec2c12ee445ce23e660f5e4fe870b9d5e09"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    build_cmake -DBUILD_PKGCONFIG_FILES=ON -DBUILD_CODEC=OFF -DWITH_ASTYLE=OFF -DBUILD_TESTING=OFF
}

ffbuild_configure() {
    echo $(ffbuild_enable libopenjpeg)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libopenjpeg)
}
