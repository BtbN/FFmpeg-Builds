#!/bin/bash
set -e

if [[ $# != 2 ]]; then
    echo "Missing arguments"
    exit -1
fi

if [[ -z "$GITHUB_REPOSITORY" || -z "$GITHUB_TOKEN" || -z "$GITHUB_ACTOR" ]]; then
    echo "Missing environment"
    exit -1
fi

INPUTS="$1"
TAGNAME="$2"

WIKIPATH="tmp_wiki"
WIKIFILE="Latest.md"
git clone "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.wiki.git" "${WIKIPATH}"

echo "# Latest Autobuilds" > "${WIKIPATH}/${WIKIFILE}"
for f in "${INPUTS}"/*.txt; do
    VARIANT="$(basename "${f::-4}")"
    echo >> "${WIKIPATH}/${WIKIFILE}"
    echo "[${VARIANT}](https://github.com/${GITHUB_REPOSITORY}/releases/download/${TAGNAME}/$(cat "${f}"))" >> "${WIKIPATH}/${WIKIFILE}"
done

cd "${WIKIPATH}"
git config user.email "actions@github.com"
git config user.name "Github Actions"
git add "$WIKIFILE"
git commit -m "Update latest version info"
git push

cd ..
rm -rf "$WIKIPATH"
