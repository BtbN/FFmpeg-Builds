#!/bin/bash

SCRIPT_REPO="https://github.com/libsndfile/libsamplerate.git"
SCRIPT_COMMIT="2ccde9568cca73c7b32c97fefca2e418c16ae5e3"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    build_cmake -DBUILD_SHARED_LIBS=NO -DBUILD_TESTING=NO -DLIBSAMPLERATE_EXAMPLES=OFF -DLIBSAMPLERATE_INSTALL=YES
}
