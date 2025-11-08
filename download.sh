#!/bin/bash
set -xe
cd "$(dirname "$0")"
source util/vars.sh dl only
source util/build_helpers.sh

# Use shared Docker environment setup
setup_docker_env

DL_SCRIPT_DIR="$(mktemp -d)"
trap "rm -rf -- '$DL_SCRIPT_DIR'" EXIT

mkdir -p "${PWD}"/.cache/downloads

for STAGE in scripts.d/*.sh scripts.d/*/*.sh; do
	# Use parameter expansion instead of basename | sed
	local name="${STAGE##*/}"
	STAGENAME="${name%.sh}"

	cat <<-EOF >"${DL_SCRIPT_DIR}/${STAGENAME}.sh"
		set -xe -o pipefail
		shopt -s dotglob

		source /dl_functions.sh
		source "/$STAGE"
		STG="\$(ffbuild_dockerdl)"

		if [[ -z "\$STG" ]]; then
			exit 0
		fi

		# Use read to extract first field instead of cut
		read -r DLHASH _ < <(sha256sum <<<"\$STG")
		DLNAME="$STAGENAME"

		if [[ "$1" == "hashonly" ]]; then
			echo "\$DLHASH"
			exit 0
		fi

		TGT="/dldir/\${DLNAME}_\${DLHASH}.tar.xz"
		if [[ -f "\$TGT" ]]; then
			rm -f "/dldir/\${DLNAME}.tar.xz"
			ln -s "\${DLNAME}_\${DLHASH}.tar.xz" "/dldir/\${DLNAME}.tar.xz"
			exit 0
		fi

		WORKDIR="\$(mktemp -d)"
		trap "rm -rf -- '\$WORKDIR'" EXIT
		cd "\$WORKDIR"

		eval "set -e; \$STG"

		tar cpJf "\$TGT.tmp" .
		mv "\$TGT.tmp" "\$TGT"
		rm -f "/dldir/\${DLNAME}.tar.xz"
		ln -s "\${DLNAME}_\${DLHASH}.tar.xz" "/dldir/\${DLNAME}.tar.xz"
	EOF
done

docker run -i $TTY_ARG --rm "${UIDARGS[@]}" -v "${DL_SCRIPT_DIR}":/stages -v "${PWD}/.cache/downloads":/dldir -v "${PWD}/scripts.d":/scripts.d -v "${PWD}/util/dl_functions.sh":/dl_functions.sh "${REGISTRY}/${REPO}/base:latest" \
	bash -c 'set -xe && for STAGE in /stages/*.sh; do bash $STAGE; done'
