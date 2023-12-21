#!/bin/bash

SCRIPT_REPO="https://svn.code.sf.net/p/zapping/svn/trunk/vbi"
SCRIPT_REV="4270"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "RUN --mount=src=${SELF},dst=/stage.sh --mount=src=patches/zvbi,dst=/patches run_stage /stage.sh"
}

ffbuild_dockerdl() {
    echo "retry-tool sh -c \"rm -rf zvbi && svn checkout '${SCRIPT_REPO}@${SCRIPT_REV}' zvbi\" && cd zvbi"
}

ffbuild_dockerbuild() {
    for patch in /patches/*.patch; do
        echo "Applying $patch"
        patch -p1 < "$patch"
    done

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --without-doxygen
        --without-x
        --disable-dvb
        --disable-bktr
        --disable-nls
        --disable-proxy
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
    make -C src -j$(nproc)
    make -C src install
    make SUBDIRS=. install

    sed -i "s/\/[^ ]*libiconv.a/-liconv/" "$FFBUILD_PREFIX"/lib/pkgconfig/zvbi-0.2.pc
}

ffbuild_configure() {
    echo --enable-libzvbi
}

ffbuild_unconfigure() {
    echo --disable-libzvbi
}
