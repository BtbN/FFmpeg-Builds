#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_enabled() {
    [[ $ADDINS_STR == *4.4* ]] && return -1
    return 0
}

ffbuild_dockerdl() {
    return 0
}

ffbuild_dockerbuild() {
    return 0
}
