#!/bin/bash

ffbuild_enabled() {
    [[ $TARGET == linux* ]]
}

ffbuild_dockerfinal() {
    to_df "RUN find /lib /usr/lib -maxdepth 1 -and -type l -and -name '*.so' -delete"
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

ffbuild_ldflags() {
    if [[ $VARIANT != *shared* ]]; then
        echo "-pie -fPIE -static"
    fi
}

ffbuild_configure() {
    if [[ $VARIANT == *shared* ]]; then
        # Can't escape hell
        echo --extra-ldexeflags=\'-Wl,-rpath='\\\\\\\$\\\$ORIGIN'\\ -Wl,-rpath='\\\\\\\$\\\$ORIGIN/../lib'\'
    fi
}
