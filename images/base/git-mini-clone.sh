#!/bin/bash
set -xe
REPO="$1"
REF="$2"
DEST="$3"
git init "$DEST"
git -C "$DEST" remote add origin "$REPO"

retry-tool git -C "$DEST" fetch --depth=1 origin "$REF"

git -C "$DEST" config advice.detachedHead false
git -C "$DEST" checkout FETCH_HEAD
