#!/usr/bin/env bash
set -eo pipefail
cd "$(dirname "$0")"
../download.sh hashonly | sha256sum | cut -d" " -f1
