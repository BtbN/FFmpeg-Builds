#!/bin/bash
set -e
shopt -s globstar
cd "$(dirname "$0")"
source util/vars.sh

export LC_ALL=C.UTF-8

rm -f Dockerfile Dockerfile.{dl,final,dl.final}

layername() {
    printf "layer-"
    basename "$1" | sed 's/.sh$//'
}

to_df() {
    _of="${TODF:-Dockerfile}"
    printf "$@" >> "$_of"
    echo >> "$_of"
}

###
### Generate main Dockerfile
###

exec_dockerstage() {
    SCRIPT="$1"
    (
        SELF="$SCRIPT"
        STAGENAME="$(basename "$SCRIPT" | sed 's/.sh$//')"
        source util/dl_functions.sh
        source "$SCRIPT"

        ffbuild_enabled || exit 0

        to_df "ENV SELF=\"$SELF\" STAGENAME=\"$STAGENAME\""

        STG="$(ffbuild_dockerdl)"
        if [[ -n "$STG" ]]; then
            HASH="$(sha256sum <<<"$STG" | cut -d" " -f1)"
            export SELFCACHE=".cache/downloads/${STAGENAME}_${HASH}.tar.xz"
        fi

        ffbuild_dockerstage || exit $?
    )
}

export TODF="Dockerfile"

to_df "FROM ${REGISTRY}/${REPO}/base-${TARGET}:latest AS base"
to_df "ENV TARGET=$TARGET VARIANT=$VARIANT REPO=$REPO ADDINS_STR=$ADDINS_STR"
to_df "COPY util/run_stage.sh /usr/bin/run_stage"

for addin in "${ADDINS[@]}"; do
(
    source addins/"${addin}.sh"
    type ffbuild_dockeraddin &>/dev/null && ffbuild_dockeraddin || true
)
done

PREVLAYER="base"
for ID in $(ls -1d scripts.d/??-* | sed -s 's|^.*/\(..\).*|\1|' | sort -u); do
    LAYER="layer-$ID"

    for STAGE in scripts.d/$ID-*; do
        to_df "FROM $PREVLAYER AS $(layername "$STAGE")"

        if [[ -f "$STAGE" ]]; then
            exec_dockerstage "$STAGE"
        else
            for STAGE in "${STAGE}"/??-*; do
                exec_dockerstage "$STAGE"
            done
        fi
    done

    to_df "FROM $PREVLAYER AS $LAYER"
    for STAGE in scripts.d/$ID-*; do
        if [[ -f "$STAGE" ]]; then
            SCRIPT="$STAGE"
        else
            SCRIPTS=( "$STAGE"/??-* )
            SCRIPT="${SCRIPTS[-1]}"
        fi

        (
            SELF="$SCRIPT"
            SELFLAYER="$(layername "$STAGE")"
            source "$SCRIPT"
            ffbuild_enabled || exit 0
            ffbuild_dockerlayer || exit $?
            TODF="Dockerfile.final" PREVLAYER="__PREVLAYER__" \
                ffbuild_dockerfinal || exit $?
        )
    done

    PREVLAYER="$LAYER"
done

to_df "FROM base"
sed "s/__PREVLAYER__/$PREVLAYER/g" Dockerfile.final | sort -u >> Dockerfile
rm Dockerfile.final

###
### Compile list of configure arguments and add them to the final Dockerfile
###

get_output() {
    (
        SELF="$1"
        source $1
        if ffbuild_enabled; then
            ffbuild_$2 || exit 0
        else
            ffbuild_un$2 || exit 0
        fi
    )
}

source "variants/${TARGET}-${VARIANT}.sh"

for addin in ${ADDINS[*]}; do
    source "addins/${addin}.sh"
done

export FFBUILD_PREFIX="$(docker run --rm "$IMAGE" bash -c 'echo $FFBUILD_PREFIX')"

for script in scripts.d/**/*.sh; do
    FF_CONFIGURE+=" $(get_output $script configure)"
    FF_CFLAGS+=" $(get_output $script cflags)"
    FF_CXXFLAGS+=" $(get_output $script cxxflags)"
    FF_LDFLAGS+=" $(get_output $script ldflags)"
    FF_LDEXEFLAGS+=" $(get_output $script ldexeflags)"
    FF_LIBS+=" $(get_output $script libs)"
done

FF_CONFIGURE="$(xargs <<< "$FF_CONFIGURE")"
FF_CFLAGS="$(xargs <<< "$FF_CFLAGS")"
FF_CXXFLAGS="$(xargs <<< "$FF_CXXFLAGS")"
FF_LDFLAGS="$(xargs <<< "$FF_LDFLAGS")"
FF_LDEXEFLAGS="$(xargs <<< "$FF_LDEXEFLAGS")"
FF_LIBS="$(xargs <<< "$FF_LIBS")"

to_df "ENV \\"
to_df "    FF_CONFIGURE=\"$FF_CONFIGURE\" \\"
to_df "    FF_CFLAGS=\"$FF_CFLAGS\" \\"
to_df "    FF_CXXFLAGS=\"$FF_CXXFLAGS\" \\"
to_df "    FF_LDFLAGS=\"$FF_LDFLAGS\" \\"
to_df "    FF_LDEXEFLAGS=\"$FF_LDEXEFLAGS\" \\"
to_df "    FF_LIBS=\"$FF_LIBS\""
