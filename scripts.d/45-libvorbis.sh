#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/vorbis.git"
SCRIPT_COMMIT="851cce991da34adf5e1f3132588683758a6369ec"

ffbuild_depends() {
    echo base
    echo libogg
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    run_autogen build_autotools --disable-oggtest
}

ffbuild_configure() {
    echo $(ffbuild_enable libvorbis)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libvorbis)
}
