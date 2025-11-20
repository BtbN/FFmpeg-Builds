#!/bin/bash

SCRIPT_REPO="https://aomedia.googlesource.com/aom"
SCRIPT_COMMIT="1e900cac01098ba2b996dab9683193daec971e2e"

ffbuild_depends() {
    echo base
    echo vmaf
}

ffbuild_enabled() {
    [[ $TARGET == winarm64 ]] && return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "RUN --mount=src=${SELF},dst=/stage.sh --mount=src=${SELFCACHE},dst=/cache.tar.xz --mount=src=patches/aom,dst=/patches run_stage /stage.sh"
}

ffbuild_dockerbuild() {
    for patch in /patches/*.patch; do
        echo "Applying $patch"
        git am < "$patch"
    done

    mkdir -p cmbuild
    cd cmbuild

    # Workaround broken build system
    export CFLAGS="$CFLAGS -pthread -I/opt/ffbuild/include/libvmaf"

    build_cmake -DENABLE_EXAMPLES=NO -DENABLE_TESTS=NO -DENABLE_TOOLS=NO -DCONFIG_TUNE_VMAF=1 ..

    echo "Requires.private: libvmaf" >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/aom.pc
}

ffbuild_configure() {
    echo $(ffbuild_enable libaom)
}

ffbuild_unconfigure() {
    echo $(ffbuild_disable libaom)
}
