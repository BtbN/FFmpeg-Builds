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

    if [[ $VARIANT == *shared* ]]; then
        # Emit a placeholder rather than a pre-escaped $ORIGIN.
        #
        # A literal $ORIGIN written here has to survive, in order: xargs and
        # printf in generate.sh, Dockerfile ENV parsing, ffmpeg configure's
        # append() eval, make expanding config.mak, and finally the shell that
        # runs the link. Each strips escapes, and the count is not stable --
        # the xargs added in 281ab29 (2024-03-14) silently ate one level and
        # every linux shared build since has shipped RPATH "-Wl:../lib"
        # instead of "$ORIGIN:$ORIGIN/../lib".
        #
        # build.sh substitutes @ORIGIN@ inside the container instead, one
        # shell layer away from configure, where the escaping is knowable.
        echo -Wl,-rpath=@ORIGIN@
        echo -Wl,-rpath=@ORIGIN@/../lib
    fi
}
