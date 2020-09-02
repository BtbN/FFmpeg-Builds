#!/bin/bash
set -e

cd "$(dirname "$0")"

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Invalid Arguments"
    exit -1
fi

TARGET="$1"
VARIANT="${2:-gpl}"
REPO="${GITHUB_REPOSITORY:-btbn/ffmpeg-builds}"
REPO="${REPO,,}"

./generate.sh "$TARGET" "$VARIANT"

exec docker build -t "$REPO/$TARGET-$VARIANT:latest" .
