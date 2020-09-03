#!/bin/bash
set -xe
cd "$(dirname "$0")"
source util/vars.sh

./generate.sh "$TARGET" "$VARIANT"

exec docker build -t "$IMAGE" .
