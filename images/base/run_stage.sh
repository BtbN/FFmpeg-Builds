#!/bin/bash
set -xe
source /stage.sh
ffbuild_dockerbuild
rm /stage.sh
rm -rf "$FFBUILD_PREFIX"/bin
