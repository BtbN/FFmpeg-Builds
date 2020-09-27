#!/bin/bash

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Invalid Arguments"
    exit -1
fi

TARGET="$1"
VARIANT="${2:-gpl}"
REPO="${GITHUB_REPOSITORY:-btbn/ffmpeg-builds}"
REPO="${REPO,,}"
REGISTRY="docker.pkg.github.com"
BASE_IMAGE="${REGISTRY}/${REPO}/base:latest"
TARGET_IMAGE="${REGISTRY}/${REPO}/base-${TARGET}:latest"
IMAGE="${REGISTRY}/${REPO}/${TARGET}-${VARIANT}:latest"

if ! [[ -f "variants/${TARGET}-${VARIANT}.sh" ]]; then
    echo "Invalid target/variant"
    exit -1
fi

ffbuild_configure() {
    return 0
}

ffbuild_unconfigure() {
    return 0
}

ffbuild_cflags() {
    return 0
}

ffbuild_uncflags() {
    return 0
}

ffbuild_cxxflags() {
    return 0
}

ffbuild_uncxxflags() {
    return 0
}

ffbuild_ldflags() {
    return 0
}

ffbuild_unldflags() {
    return 0
}

ffbuild_libs() {
    return 0
}

ffbuild_unlibs() {
    return 0
}
