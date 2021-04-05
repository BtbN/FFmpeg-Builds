#!/bin/bash
set -xe
mkdir -p /stage
cd /stage
source /stage.sh
ffbuild_dockerbuild
rm -rf /stage /stage.sh "$FFBUILD_PREFIX"/bin
