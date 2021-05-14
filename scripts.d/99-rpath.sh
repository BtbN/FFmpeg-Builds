#!/bin/bash

ffbuild_enabled() {
    [[ $TARGET == linux* ]]
}

ffbuild_dockerfinal() {
    return 0
}

ffbuild_dockerlayer() {
    return 0
}

ffbuild_dockerstage() {
    return 0
}

ffbuild_dockerbuild() {
    return 0
}

ffbuild_configure() {
    if [[ $VARIANT == *shared* ]]; then
        # Can't escape escape hell
        echo --extra-ldexeflags=\'-Wl,-rpath='\\\\\\\$\\\$ORIGIN'\\ -Wl,-rpath='\\\\\\\$\\\$ORIGIN/../lib'\'
    fi
}
