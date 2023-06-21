#!/bin/bash
set -eo pipefail
printf dlcache_
tail -n+3 Dockerfile.dl | sha256sum | cut -d' ' -f1
