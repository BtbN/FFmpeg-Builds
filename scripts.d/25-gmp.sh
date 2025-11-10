#!/bin/bash

SCRIPT_REPO="https://github.com/BtbN/gmplib.git"
SCRIPT_COMMIT="9994908f090c694f8a152d660dc6852e0c48557a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    ./.bootstrap

    build_autotools --enable-maintainer-mode --with-pic
}

ffbuild_configure() {
    echo $(ffbuild_enable gmp)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable gmp)
}
