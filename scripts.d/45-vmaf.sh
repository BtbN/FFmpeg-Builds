#!/bin/bash

SCRIPT_REPO="https://github.com/Netflix/vmaf.git"
SCRIPT_COMMIT="86da14d0306a138fd3f01319860b905169746516"

# nv-codec-headers (needed at build time for libvmaf's CUDA headers).
SCRIPT_REPO2="https://github.com/FFmpeg/nv-codec-headers.git"
SCRIPT_COMMIT2="eddcea9e27f6b772057c9b3f87de2cc1737faffc"

CUDA_VERSION="13.4"
CUDA_APT_PKGS=("cuda-nvcc-${CUDA_VERSION//./-}")
CUDA_PATH="/usr/local/cuda-${CUDA_VERSION}"
CUDA_KEYRING_SHA256_X86_64="f7f474b5f6a4adf987aa587920df00e713285958ef6a913dda1945a544a3099e"
CUDA_KEYRING_SHA256_SBSA="bf74da243be6737d338a8e6f03469eb983825bba7b6dbd0b6d6a6f60229cbb6e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "RUN --mount=src=${SELF},dst=/stage.sh --mount=src=${SELFCACHE},dst=/cache.tar.xz --mount=src=patches/vmaf,dst=/patches run_stage /stage.sh"
}

ffbuild_dockerdl() {
    default_dl .
    echo "git-mini-clone \"$SCRIPT_REPO2\" \"$SCRIPT_COMMIT2\" ffnvcodec"
}

# Static libvmaf contains C++ (svm.cpp). AOM's CMake and FFmpeg's configure read
# the public Libs: line, so the C++ runtime goes there and in Libs.private:.
# -ldl is Linux-only and must never reach a MinGW target.
vmaf_fix_pc() {
    local pc="$FFBUILD_DESTPREFIX/lib/pkgconfig/libvmaf.pc"
    local extra="-lstdc++"
    if (( $1 )) && [[ $TARGET == linux* ]]; then
        extra+=" -ldl"
    fi

    sed -i "/^Libs:/ s/\$/ $extra/" "$pc" || return 1
    grep -q "^Libs:.* ${extra}\$" "$pc" || { echo "ERROR: failed to patch $pc"; return 1; }

    echo "---- Final libvmaf.pc for TARGET=$TARGET ----"
    cat "$pc"
}

ffbuild_dockerbuild() {
    for patch in /patches/*.patch; do
        echo "Applying $patch"
        git am < "$patch" || return 1
    done
    
    # Kill build of unused and broken tools
    echo > libvmaf/tools/meson.build

    sed -i -E 's/([^.>:_[:alnum:]])swap\(/\1libsvm_swap(/g' libvmaf/src/svm.cpp
    sed -i -E 's/([^.>:_[:alnum:]])min\(/\1libsvm_min(/g' libvmaf/src/svm.cpp
    sed -i -E 's/([^.>:_[:alnum:]])max\(/\1libsvm_max(/g' libvmaf/src/svm.cpp

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Dbuilt_in_models=true
        -Denable_tests=false
        -Denable_docs=false
        -Denable_float=true
    )

    if [[ $TARGET == *32 ]]; then
        myconf+=(
            -Denable_avx512=false
            -Denable_asm=false
        )
    else
        myconf+=(
            -Denable_avx512=true
            -Denable_asm=true
        )
    fi

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target: $TARGET"
        return -1
    fi

    if (( cuda )); then
        # Install nv-codec-headers
        local ffnv="ffnvcodec"
        make -C "$ffnv" PREFIX="$FFBUILD_PREFIX" install || return 1
        export CPATH="$FFBUILD_PREFIX/include${CPATH:+:$CPATH}"

        # Pick NVIDIA's repo from the build container itself
        local cuda_distro cuda_arch keyring_sha256
        cuda_distro="$(. /etc/os-release && [[ $ID == ubuntu ]] && echo "ubuntu${VERSION_ID//./}")"
        [[ -n $cuda_distro ]] || { echo "ERROR: build container is not Ubuntu"; return 1; }

        case "$(dpkg --print-architecture)" in
            amd64) cuda_arch="x86_64"; keyring_sha256="$CUDA_KEYRING_SHA256_X86_64" ;;
            arm64) cuda_arch="sbsa";   keyring_sha256="$CUDA_KEYRING_SHA256_SBSA" ;;
            *) echo "ERROR: no CUDA repo for $(dpkg --print-architecture)"; return 1 ;;
        esac

        local cuda_repo="https://developer.download.nvidia.com/compute/cuda/repos/${cuda_distro}/${cuda_arch}"
        echo "Using CUDA repo: $cuda_repo"

        # Verify the keyring against the pinned hash before trusting it.
        curl -fsSL -o cuda-keyring.deb "${cuda_repo}/cuda-keyring_1.1-1_all.deb" || return 1
        echo "${keyring_sha256}  cuda-keyring.deb" | sha256sum -c - || {
            echo "ERROR: CUDA keyring hash mismatch; actual:"
            sha256sum cuda-keyring.deb
            return 1
        }
        dpkg -i cuda-keyring.deb || return 1
        rm -f cuda-keyring.deb

        apt-get update || return 1
        apt-get install -y --no-install-recommends "${CUDA_APT_PKGS[@]}" gcc g++ || return 1
        export PATH="${CUDA_PATH}/bin:$PATH"

        # NVCC only generates device fatbins; use the build machine's compiler,
        # never the MinGW cross compiler.
        export NVCC_PREPEND_FLAGS="-ccbin /usr/bin/g++"


        "${CUDA_PATH}/bin/nvcc" --version || return 1
        command -v bin2c || return 1

        myconf+=(
            -Denable_cuda=true 
            -Denable_nvcc=true
        )
    fi

    # Build dir must live inside libvmaf since the CUDA kernel rules use relative
    # ../src include paths.
    cd libvmaf || return 1
    mkdir build || return 1
    cd build || return 1

    # BtbN's LDFLAGS (-static-libgcc, -Wl,...) are rejected by NVCC. Meson
    # records env linker flags at setup. unset them for setup only.
    if ! env -u LDFLAGS meson setup "${myconf[@]}" . ..; then
        echo "ERROR: Meson configuration failed."
        echo "---- Meson log ----"
        cat meson-logs/meson-log.txt
        return 1
    fi

    ninja -j"$(nproc)" || return 1
    DESTDIR="$FFBUILD_DESTDIR" ninja install || return 1

    vmaf_fix_pc "$cuda" || return 1

    if (( cuda )); then
        # Keep the SDK out of this stage's cached layer (only DESTPREFIX is used).
        apt-get purge -y --autoremove "${CUDA_APT_PKGS[@]}" || true
        rm -rf /usr/local/cuda* /var/lib/apt/lists/*
        apt-get clean
    fi
}

ffbuild_configure() {
    (( $(ffbuild_ffver) >= 501 )) || return 0
    echo --enable-libvmaf
}

ffbuild_unconfigure() {
    echo --disable-libvmaf
}
