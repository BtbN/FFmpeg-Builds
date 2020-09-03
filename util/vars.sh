#!/bin/bash

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Invalid Arguments"
    exit -1
fi

TARGET="$1"
VARIANT="${2:-gpl}"
REPO="${DOCKER_REPO:-btbn/ffmpeg-builder}"
IMAGE="$REPO:$TARGET-$VARIANT"
