#!/bin/bash

SCRIPT_REPO="https://github.com/breakfastquay/rubberband.git"
SCRIPT_COMMIT="e4296ac80b1170018a110bc326fd0d45a0eb27d6"

ffbuild_depends() {
    echo base
    echo fftw3
    echo libsamplerate
}

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    build_meson -Dfft=fftw -Dresampler=libsamplerate
}

ffbuild_configure() {
    echo $(ffbuild_enable librubberband)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable librubberband)
}
