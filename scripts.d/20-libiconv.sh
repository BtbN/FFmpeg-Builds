#!/bin/bash

SCRIPT_REPO="https://https.git.savannah.gnu.org/git/libiconv.git"
SCRIPT_MIRROR="git://git.git.savannah.gnu.org/libiconv.git"
SCRIPT_COMMIT="b66b2f548166b667a7c48777ded7506a43971b21"

SCRIPT_REPO2="https://https.git.savannah.gnu.org/git/gnulib.git"
SCRIPT_MIRROR2="https://github.com/coreutils/gnulib.git"
SCRIPT_COMMIT2="6a9227219c093b9f8c2a22f69c876ade7269e8dd"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    echo "retry-tool sh -c \"rm -rf iconv && git clone '$SCRIPT_MIRROR' iconv\" && git -C iconv checkout \"$SCRIPT_COMMIT\""
    echo "cd iconv && retry-tool sh -c \"rm -rf gnulib && git clone --filter=blob:none '$SCRIPT_MIRROR2' gnulib\" && git -C gnulib checkout \"$SCRIPT_COMMIT2\" && rm -rf gnulib/.git"
}

ffbuild_dockerbuild() {
    # No automake 1.18 packaged anywhere yet.
    sed -i 's/-1.18/-1.17/' Makefile.devel libcharset/Makefile.devel

    (unset CC CFLAGS GMAKE && ./autogen.sh)

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-extra-encodings
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-iconv
}

ffbuild_unconfigure() {
    echo --disable-iconv
}
