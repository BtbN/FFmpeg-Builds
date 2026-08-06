#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_enabled() {
    [[ $TARGET == linux* ]]
}

ffbuild_dockerfinal() {
    return 0
}

ffbuild_dockerdl() {
    true
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

ffbuild_ldexeflags() {
    echo '-pie'

    # The $ORIGIN rpath flags for shared linux builds are deliberately NOT
    # emitted here -- build.sh appends them inside the container instead.
    #
    # A literal $ORIGIN written here would have to survive, in order: xargs and
    # printf in generate.sh, Dockerfile ENV parsing, ffmpeg configure's append()
    # eval, make expanding config.mak, and finally the shell that runs the link.
    # Each strips escapes and the required count is not stable: the xargs added
    # in 281ab29 (2024-03-14) silently ate one level, and every linux shared
    # build since has shipped RPATH "-Wl:../lib" instead of
    # "$ORIGIN:$ORIGIN/../lib".
}
