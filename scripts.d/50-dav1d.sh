#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/dav1d.git"
SCRIPT_COMMIT="e7c280e4cde445589c875dbd97da61579483f605"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    build_meson
}

ffbuild_configure() {
    echo $(ffbuild_enable libdav1d)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libdav1d)
}
