#!/bin/bash
set -xe
REPO="$1"
REF="$2"
DEST="$3"
git init "$DEST"
git -C "$DEST" remote add origin "$REPO"

RETRY_COUNTER=0
MAX_RETRY=15
while [[ $RETRY_COUNTER -lt $MAX_RETRY ]]; do
    timeout 120 git -C "$DEST" fetch --depth=1 origin "$REF" && break || sleep 10
    RETRY_COUNTER=$(( $RETRY_COUNTER + 1 ))
    echo "Retry $RETRY_COUNTER..."
done
if [[ $RETRY_COUNTER -ge $MAX_RETRY ]]; then
    echo "Max retry count exceeded."
    exit 1
fi

git -C "$DEST" config advice.detachedHead false
git -C "$DEST" checkout FETCH_HEAD
