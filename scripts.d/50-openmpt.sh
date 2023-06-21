#!/bin/bash

SCRIPT_REPO="https://source.openmpt.org/svn/openmpt/trunk/OpenMPT"
SCRIPT_REV="19424"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    to_df "RUN retry-tool sh -c \"rm -rf openmpt && svn checkout '${SCRIPT_REPO}@${SCRIPT_REV}' openmpt\""
}

ffbuild_dockerbuild() {
    cd "$FFBUILD_DLDIR"/openmpt

    local myconf=(
        PREFIX="$FFBUILD_PREFIX"
        CXXSTDLIB_PCLIBSPRIVATE="-lstdc++"
        VERBOSE=2
        STATIC_LIB=1
        SHARED_LIB=0
        DYNLINK=0
        EXAMPLES=0
        OPENMPT123=0
        IN_OPENMPT=0
        XMP_OPENMPT=0
        DEBUG=0
        OPTIMIZE=1
        TEST=0
        MODERN=1
        FORCE_DEPS=1
        NO_MINIMP3=0
        NO_ZLIB=0
        NO_OGG=0
        NO_VORBIS=0
        NO_VORBISFILE=0
        NO_MPG123=1
        NO_SDL2=1
        NO_PULSEAUDIO=1
        NO_SNDFILE=1
        NO_PORTAUDIO=1
        NO_PORTAUDIOCPP=1
        NO_FLAC=1
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            CONFIG=mingw64-"$TARGET"
        )
        export CPPFLAGS="$CPPFLAGS -DMPT_WITH_MINGWSTDTHREADS"
    elif [[ $TARGET == linux* ]]; then
        myconf+=(
            CONFIG=gcc
            TOOLCHAIN_PREFIX="$FFBUILD_CROSS_PREFIX"
        )
    else
        echo "Unknown target"
        return -1
    fi

    make -j$(nproc) "${myconf[@]}" all install
    rm -r "$FFBUILD_PREFIX"/share/doc/libopenmpt
}

ffbuild_configure() {
    echo --enable-libopenmpt
}

ffbuild_unconfigure() {
    echo --disable-libopenmpt
}
