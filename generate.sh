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

default_dl() {
    to_df "RUN git-mini-clone \"$SCRIPT_REPO\" \"$SCRIPT_COMMIT\" \"$1\""
}

###
### Generate download Dockerfile
###

exec_dockerstage_dl() {
    SCRIPT="$1"
    (
        SELF="$SCRIPT"
        SELFLAYER="$(layername "$STAGE")"
        source "$SCRIPT"
        ffbuild_dockerdl || exit $?
        TODF="Dockerfile.dl.final" ffbuild_dockerlayer_dl || exit $?
    )
}

export TODF="Dockerfile.dl"

to_df "FROM ${REGISTRY}/${REPO}/base:latest AS base"
to_df "ENV TARGET=$TARGET VARIANT=$VARIANT REPO=$REPO ADDINS_STR=$ADDINS_STR"
to_df "WORKDIR \$FFBUILD_DLDIR"

for STAGE in scripts.d/*.sh scripts.d/*/*.sh; do
    to_df "FROM base AS $(layername "$STAGE")"
    exec_dockerstage_dl "$STAGE"
done

to_df "FROM base AS intermediate"
cat Dockerfile.dl.final >> "$TODF"
rm Dockerfile.dl.final

to_df "FROM scratch"
to_df "COPY --from=intermediate /opt/ffdl/. /"

if [[ "$TARGET" == "dl" && "$VARIANT" == "only" ]]; then
    exit 0
fi

DL_IMAGE="${DL_IMAGE_RAW}:$(./util/get_dl_cache_tag.sh)"

###
### Generate main Dockerfile
###

exec_dockerstage() {
    SCRIPT="$1"
    (
        SELF="$SCRIPT"
        source "$SCRIPT"

        ffbuild_enabled || exit 0

        to_df "ENV SELF=\"$SELF\""
        ffbuild_dockerstage || exit $?
    )
}

export TODF="Dockerfile"

to_df "FROM ${REGISTRY}/${REPO}/base-${TARGET}:latest AS base"
to_df "ENV TARGET=$TARGET VARIANT=$VARIANT REPO=$REPO ADDINS_STR=$ADDINS_STR"

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
