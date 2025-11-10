#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/dav1d.git"
SCRIPT_COMMIT="fcbc3d1b93f91c709293ed9faea8b7cbcac9030b"

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
