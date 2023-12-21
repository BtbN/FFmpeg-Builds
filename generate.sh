#!/bin/bash
set -e
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

        set -x

        STG="$(ffbuild_dockerdl)"
        if [[ -n "$STG" ]]; then
            HASH="$(sha256sum <<<"$STG" | cut -d" " -f1)"
            to_df "ADD .cache/downloads/${STAGENAME}_${HASH}.tar.xz /${STAGENAME}"
            to_df "WORKDIR /${STAGENAME}"
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
