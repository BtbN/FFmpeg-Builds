#!/bin/bash
set -e

cd "$(dirname "$0")"
rm -f Dockerfile

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Invalid Arguments"
    exit -1
fi

TARGET="$1"
VARIANT="${2:-gpl}"
REPO="${GITHUB_REPOSITORY:-btbn/ffmpeg-builds}"
REPO="${REPO,,}"

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
