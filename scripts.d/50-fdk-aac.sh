#!/bin/bash

SCRIPT_REPO="https://github.com/mstorsjo/fdk-aac.git"
SCRIPT_COMMIT="d8e6b1a3aa606c450241632b64b703f21ea31ce3"

ffbuild_enabled() {
    [[ $VARIANT == nonfree* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    run_autogen
    build_autotools --disable-example
}

ffbuild_configure() {
    echo $(ffbuild_enable libfdk-aac)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libfdk-aac)
}
