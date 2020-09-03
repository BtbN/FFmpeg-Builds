#!/bin/bash
set -xe
cd "$(dirname "$0")"
source util/vars.sh

rm -f Dockerfile

to_df() {
    printf "$@" >> Dockerfile
    echo >> Dockerfile
}

to_df "FROM $REPO:base-$TARGET"
to_df "ENV TARGET=$TARGET VARIANT=$VARIANT REPO=$REPO"
to_df "ENV FFBUILD_PREFIX=/opt/ffbuild PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig"

for script in scripts.d/*.sh; do
(
    SELF="$script"
    source $script
    ffbuild_enabled || exit 0
    ffbuild_dockerstage || exit $?
)
done
