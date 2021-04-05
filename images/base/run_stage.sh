#!/bin/bash
set -xe
mkdir -p /stage
source "$1"
cd /stage
ffbuild_dockerbuild
rm -rf /stage "$FFBUILD_PREFIX"/bin
