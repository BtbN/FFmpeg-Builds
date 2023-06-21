#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_enabled() {
    [[ $TARGET == linux* ]]
}

ffbuild_dockerfinal() {
    return 0
}

ffbuild_dockerdl() {
    return 0
}

ffbuild_dockerlayer() {
    return 0
}

ffbuild_dockerstage() {
    return 0
}

ffbuild_dockerlayer_dl() {
    return 0
}

ffbuild_dockerbuild() {
    return 0
}

ffbuild_ldexeflags() {
    echo '-pie'

    if [[ $VARIANT == *shared* ]]; then
        # Can't escape escape hell
        echo -Wl,-rpath='\\\\\\\$\\\$ORIGIN'
        echo -Wl,-rpath='\\\\\\\$\\\$ORIGIN/../lib'
    fi
}
