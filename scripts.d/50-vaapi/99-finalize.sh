#!/bin/bash

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    rm "$FFBUILD_PREFIX"/lib/lib*.so* || true
    rm "$FFBUILD_PREFIX"/lib/*.la || true
}
