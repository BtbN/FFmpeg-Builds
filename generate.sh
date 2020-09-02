#!/bin/bash
set -xe
cd "$(dirname "$0")"
source util/vars.sh

rm -f Dockerfile

to_df() {
    printf "$@" >> Dockerfile
    echo >> Dockerfile
}

to_df "FROM $REPO/base-$TARGET:latest"
to_df "ENV TARGET $TARGET"
to_df "ENV VARIANT $VARIANT"
to_df "ENV REPO $REPO"

to_df "ENV FFPREFIX /opt/ffbuild"
to_df "ENV PKG_CONFIG_LIBDIR /opt/ffbuild/lib/pkgconfig"

for script in scripts.d/*.sh; do
(
    SELF="$script"
    source $script
    ffbuild_enabled || exit 0
    ffbuild_dockerstage || exit $?
)
done
