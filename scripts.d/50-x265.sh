#!/bin/bash

X265_REPO="https://github.com/videolan/x265.git"
X265_COMMIT="83e2d7fb0b181b2d86498b2e729499e7f184e1ef"

ffbuild_enabled() {
    [[ $VARIANT == gpl* ]] || return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git clone "$X265_REPO" x265
    cd x265
    git checkout "$X265_COMMIT"

    if [[ $TARGET != *32 ]]; then
        mkdir 8bit 10bit 12bit

        cd 12bit
        cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DENABLE_SHARED=OFF -DENABLE_CLI=OFF -DMAIN12=ON ../source
        make -j$(nproc)
        cp libx265.a ../8bit/libx265_main12.a

        cd ../10bit
        cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DENABLE_SHARED=OFF -DENABLE_CLI=OFF ../source
        make -j$(nproc)
        cp libx265.a ../8bit/libx265_main10.a

        cd ../8bit
        cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DEXTRA_LIB="x265_main10.a;x265_main12.a" -DEXTRA_LINK_FLAGS=-L. -DLINKED_10BIT=ON -DLINKED_12BIT=ON -DENABLE_SHARED=OFF -DENABLE_CLI=OFF ../source
        make -j$(nproc)
        mv libx265.a libx265_main.a

        ${FFBUILD_CROSS_PREFIX}ar -M <<EOF
CREATE libx265.a
ADDLIB libx265_main.a
ADDLIB libx265_main10.a
ADDLIB libx265_main12.a
SAVE
END
EOF
    else
        mkdir 8bit
        cd 8bit
        cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DENABLE_SHARED=OFF -DENABLE_CLI=OFF ../source
        make -j$(nproc)
    fi

    make install || return -1

    cd ../..
    rm -rf x265
}

ffbuild_configure() {
    echo --enable-libx265
}

ffbuild_unconfigure() {
    echo --disable-libx265
}

ffbuild_cflags() {
    return 0
}

ffbuild_ldflags() {
    return 0
}
