if [[ "$TARGET" != "winarm64" && "$STAGENAME" == *vmaf ]]; then
    sed -i '/exe_wrapper/d' /cross.meson
    sed -i '/^\[binaries\]/a cuda = '"'nvcc'"'' /cross.meson

    myconf+=(
        --cross-file=/cross.meson
        -Denable_asm=true
        -Denable_nvcc=true
        -Denable_cuda=true
        -Dc_args="-DVMAF_PICTURE_POOL -DOC_NEW_STYLE_INCLUDES ${CFLAGS}"
    )

    if [[ "$ADDINS_STR" == *lusoris ]]; then
        myconf+=(
            -Denable_sycl=true
        )
        # 1. Get the target triple directly from the compiler
        CTNG_TARGET=$(${CC} -dumpmachine)

        # 2. Find the absolute root of the toolchain by going one level up from the 'bin' folder
        CTNG_TOOLCHAIN=$(dirname $(dirname $(which ${CC})))
        export CTNG_TOOLCHAIN

        # 3. Get the sysroot (which you already figured out)
        CTNG_SYSROOT=$(${CC} -print-sysroot)

        # 4. Generate the config
        ICPXCFG=$(mktemp)
        export ICPXCFG
        echo "-static-intel --sysroot $CTNG_SYSROOT --gcc-toolchain=$CTNG_TOOLCHAIN --target=$CTNG_TARGET" >"$ICPXCFG"
    fi

    if [[ "$ADDINS_STR" == *legacy ]]; then
        git apply --directory=.. /patches/vmaf-nvcc-legacy.patch
    else
        git apply --directory=.. /patches/vmaf-nvcc.patch
    fi

elif [[ -z "$STAGENAME" ]]; then
    if [[ "$ADDINS_STR" == *jellyfin ]]; then
        PATCH_REPO="https://github.com/nyanmisaka/jellyfin-ffmpeg.git"
        PATCH_BRANCH="jellyfin-8.1" # branch that contains the patches
        git clone --depth 1 -b "$PATCH_BRANCH" "$PATCH_REPO" "/tmp/jellyfin-ffmpeg"
        export QUILT_PATCHES="/tmp/jellyfin-ffmpeg/debian/patches"
        quilt push -a
        if quilt status | grep -q 'Unapplied'; then
            echo "ERROR: Some patches failed to apply. Check quilt status for details." >&2
            exit 1
        fi
    fi

    if [[ "$ADDINS_STR" == *lusoris ]]; then
        PATCH_REPO="https://github.com/lusoris/vmaf.git"
        PATCH_BRANCH="master" # branch that contains the patches
        git clone --depth 1 -b "$PATCH_BRANCH" "$PATCH_REPO" "/tmp/vmaf-lusoris"
        export QUILT_PATCHES="/tmp/vmaf-lusoris/ffmpeg-patches"

        for p in $(grep -v '^\s*#' ${QUILT_PATCHES}/series.txt); do
            git apply --3way ${QUILT_PATCHES}/$p
        done
    fi

    if [[ "$ADDINS_STR" == *legacy ]]; then
        git apply /patches/ffmpeg-nvcc-legacy.patch
    else
        git apply /patches/ffmpeg-nvcc.patch
    fi

    if [[ -d "$FFBUILD_PREFIX/level-zero" ]]; then
        mkdir -p /ffbuild/prefix/lib
        cp -rav $FFBUILD_PREFIX/level-zero/* /ffbuild/prefix/lib
    fi

    echo "🩹 All patches applied successfully."
fi
