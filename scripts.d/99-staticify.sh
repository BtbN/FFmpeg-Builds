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
    if [[ $VARIANT == *shared* ]]; then
        #if [[ $TARGET == *64* ]]; then
        #    echo "-Wl,--dynamic-linker=/lib64/ld-linux-x86-64.so.2"
        #else
        #    echo "-Wl,--dynamic-linker=/lib/ld-linux.so.2"
        #fi
        return 0
    else
        echo "-pie -fPIE -static"
    fi
}

ffbuild_configure() {
    # Any dynamic executables linked against musl need its dynamic loader to run
    # Thus it's impossible to build both the libraries and the programs, since
    # with shared libs, the programs need to be dynamic, and in turn needs the musl
    # dynamic loader at runtime.
    [[ $VARIANT == *shared* ]] && echo --disable-programs
}
