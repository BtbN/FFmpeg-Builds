#!/bin/bash
set -xe
cd "$(dirname "$0")"
source util/vars.sh

rm -f Dockerfile

to_df() {
    printf "$@" >> Dockerfile
    echo >> Dockerfile
}

to_df "FROM docker.pkg.github.com/${REPO}/base-${TARGET}:latest"
to_df "ENV TARGET=$TARGET VARIANT=$VARIANT REPO=$REPO ADDINS_STR=$ADDINS_STR"

for script in scripts.d/*.sh; do
(
    SELF="$script"
    source $script
    ffbuild_enabled || exit 0
    ffbuild_dockerstage || exit $?
)
done
