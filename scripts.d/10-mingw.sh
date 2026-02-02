#!/bin/bash

SCRIPT_REPO="https://git.code.sf.net/p/mingw-w64/mingw-w64.git"
SCRIPT_COMMIT="3fedac28018c447ccdd9519c9d556340dfa1c87e"

ffbuild_depends() {
    return 0
}

ffbuild_enabled() {
    [[ $TARGET == win* ]] || return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --link --from=${SELFLAYER} /opt/mingw/. /"
    [[ -n "$COMBINING" ]] || return 0
    to_df "COPY --link --from=${SELFLAYER} /opt/mingw/. /opt/mingw"
}

ffbuild_dockerfinal() {
    to_df "COPY --link --from=${PREVLAYER} /opt/mingw/. /"
}

ffbuild_dockerdl() {
    echo "retry-tool sh -c \"rm -rf mingw && git clone '$SCRIPT_REPO' mingw\" && cd mingw && git checkout \"$SCRIPT_COMMIT\""
}

ffbuild_dockerbuild() {
    if [[ -z "$COMPILER_SYSROOT" ]]; then
        COMPILER_SYSROOT="$(${CC} -print-sysroot)/usr/${FFBUILD_TOOLCHAIN}"
    fi

    unset CC CXX LD AR CPP LIBS CCAS
    unset CFLAGS CXXFLAGS LDFLAGS CPPFLAGS CCASFLAGS
    unset PKG_CONFIG_LIBDIR

    ###
    ### mingw-w64-headers
    ###
    (
        cd mingw-w64-headers

        local myconf=(
            --host="$FFBUILD_TOOLCHAIN"
            --with-default-win32-winnt="0x601"
            --with-default-msvcrt=ucrt
            --enable-idl
            --enable-sdk=all
        )

        if [[ -L "$COMPILER_SYSROOT"/include ]]; then
            local target="$(readlink -f "$COMPILER_SYSROOT"/include)"
            mkdir -p "/opt/mingw$COMPILER_SYSROOT"
            ln -sfn "$(realpath -s --relative-to="$COMPILER_SYSROOT" "$target")" "/opt/mingw$COMPILER_SYSROOT/include"
            myconf+=( --prefix="$(realpath "$target"/..)" )
        else
            myconf+=( --prefix="$COMPILER_SYSROOT" )
        fi

        ./configure "${myconf[@]}"
        make -j$(nproc)
        make install DESTDIR="/opt/mingw"
    )

    cp -a /opt/mingw/. /

    ###
    ### mingw-w64-crt
    ###
    (
        cd mingw-w64-crt

        local myconf=(
            --prefix="$COMPILER_SYSROOT"
            --host="$FFBUILD_TOOLCHAIN"
            --with-default-msvcrt=ucrt
            --enable-wildcard
        )

        case $TARGET in
        *arm64)
            myconf+=(
                --disable-lib32
                --disable-lib64
                --enable-libarm64
            )
            ;;
        *arm32)
            myconf+=(
                --disable-lib32
                --disable-lib64
                --enable-libarm32
            )
            ;;
        *64)
            myconf+=(
                --disable-lib32
                --enable-lib64
            )
            ;;
        *32)
            myconf+=(
                --enable-lib32
                --disable-lib64
            )
            ;;
        esac

        ./configure "${myconf[@]}"
        make -j$(nproc)
        make install DESTDIR="/opt/mingw"
    )

    cp -a /opt/mingw/. /

    ###
    ### mingw-w64-libraries/winpthreads
    ###
    (
        cd mingw-w64-libraries/winpthreads

        local myconf=(
            --prefix="$COMPILER_SYSROOT"
            --host="$FFBUILD_TOOLCHAIN"
            --with-pic
            --disable-shared
            --enable-static
        )

        ./configure "${myconf[@]}"
        make -j$(nproc)
        make install DESTDIR="/opt/mingw"
    )
}

ffbuild_configure() {
    echo --disable-w32threads --enable-pthreads
}
