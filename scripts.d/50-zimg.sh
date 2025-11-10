#!/bin/bash

SCRIPT_REPO="https://github.com/sekrit-twc/zimg.git"
SCRIPT_COMMIT="df9c1472b9541d0e79c8d02dae37fdf12f189ec2"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    default_dl .
    echo "git submodule update --init --recursive --depth=1"
}

ffbuild_dockerbuild() {
    run_autogen
    build_autotools
}

ffbuild_configure() {
    echo $(ffbuild_enable libzimg)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libzimg)
}
