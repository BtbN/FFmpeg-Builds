#!/bin/bash
set -xe
cd "$(dirname "$0")"/../.cache/downloads
find . $(printf "! -name %s " $(find . -type l -exec basename -a {} + -exec readlink {} +)) -delete
