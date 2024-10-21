#!/bin/bash

SCRIPT_REPO="https://git.savannah.gnu.org/git/libiconv.git"
SCRIPT_COMMIT="eed6782cbb4651876e3c8b27ea53273f230ee8e2"

SCRIPT_REPO2="https://git.savannah.gnu.org/git/gnulib.git"
SCRIPT_COMMIT2="cc292ecda26359d5a80989bdbd1633f2f0721628"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerdl() {
    echo "retry-tool sh -c \"rm -rf iconv && git clone '$SCRIPT_REPO' iconv\" && git -C iconv checkout \"$SCRIPT_COMMIT\""
    echo "cd iconv && retry-tool sh -c \"rm -rf gnulib && git clone '$SCRIPT_REPO2' gnulib\" && git -C gnulib checkout \"$SCRIPT_COMMIT2\" && rm -rf gnulib/.git"
}

ffbuild_dockerbuild() {
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
    make install
}

ffbuild_configure() {
    echo --enable-iconv
}

ffbuild_unconfigure() {
    echo --disable-iconv
}
