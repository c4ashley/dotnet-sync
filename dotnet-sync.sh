#!/bin/bash

ROOT=$(readlink -m "$(dirname $0)")
dryrun=0
verbose=0

ARGS=$(getopt -o 'vdh' -l 'verbose,dry-run,help' -n "$0" -- "$@")
eval set -- "$ARGS"
unset ARGS
while test $# -gt 0; do
	case "$1" in
		'-h'|'--help')
			echo "USAGE: $0 [options]"
			echo ""
			echo "Options:"
			echo "  -v|--verbose  Print each directory and link command as it's being searched and executed."
			echo "  -d|--dry-run  Print the commands that would be executed, but do not execute them."
			echo "  -h|--help     Show this help text."
			exit 0 ;;
		'-v'|'--verbose') verbose=1 ;;
		'-d'|'--dry-run') dryrun=1 ;;
	esac
	shift
done

if [ $dryrun -eq 0 ]; then
	if ! test -w /usr/lib64/dotnet; then
		echo "You do not have permission to edit the /usr/lib64/dotnet directory. Try running as superuser."
		exit 1
	fi
fi

uppersyncdirs=("sdk" "sdk-manifests" "templates")
lowersyncdirs=("host" "shared" "packs")

PADDING1=""
PADDING2=""
if [ ${verbose} -eq 1 ]; then
	PADDING1="    "
	PADDING2="      "
fi

for SYNC in "${lowersyncdirs[@]}"; do
	[[ $verbose -eq 1 ]] && echo "${SYNC}"
	for SUB in "${ROOT}/.dotnet/${SYNC}"/*; do
		SUB="${SUB##*/}"
		[[ $verbose -eq 1 ]] && echo "  ${SUB}"
		if [ ! -d "/usr/lib64/dotnet/${SYNC}/${SUB}" ]; then
			[[ $verbose -eq 1 || $dryrun -eq 1 ]] && echo "${PADDING1}"ln -s "${ROOT}/.dotnet/${SYNC}/${SUB}" "/usr/lib64/dotnet/${SYNC}/${SUB}"
			[[ $dryrun -eq 0 ]] && ln -s "${ROOT}/.dotnet/${SYNC}/${SUB}" "/usr/lib64/dotnet/${SYNC}/${SUB}"
		else
			for VERSION in "${ROOT}/.dotnet/${SYNC}/${SUB}"/*; do
				VERSION="${VERSION##*/}"
				[[ $verbose -eq 1 ]] && echo "    ${VERSION}"
				if [ ! -d "/usr/lib64/dotnet/${SYNC}/${SUB}/${VERSION}" ]; then
					[[ $verbose -eq 1 || $dryrun -eq 1 ]] && echo "${PADDING2}"ln -s "${ROOT}/.dotnet/${SYNC}/${SUB}/${VERSION}" "/usr/lib64/dotnet/${SYNC}/${SUB}/${VERSION}"
					[[ $dryrun -eq 0 ]] && ln -s "${ROOT}/.dotnet/${SYNC}/${SUB}/${VERSION}" "/usr/lib64/dotnet/${SYNC}/${SUB}/${VERSION}"
				fi
			done
		fi
	done
done

for SYNC in "${uppersyncdirs[@]}"; do
	[[ $verbose -eq 1 ]] && echo "${SYNC}"
	for VERSION in "${ROOT}/.dotnet/${SYNC}"/*; do
		VERSION="${VERSION##*/}"
		[[ $verbose -eq 1 ]] && echo "  ${VERSION}"
		if [ ! -d "/usr/lib64/dotnet/${SYNC}/${VERSION}" ]; then
			[[ $verbose -eq 1 || $dryrun -eq 1 ]] && echo "${PADDING1}"ln -s "${ROOT}/.dotnet/${SYNC}/${VERSION}" "/usr/lib64/dotnet/${SYNC}/${VERSION}"
			[[ $dryrun -eq 0 ]] && ln -s "${ROOT}/.dotnet/${SYNC}/${VERSION}" "/usr/lib64/dotnet/${SYNC}/${VERSION}"
		fi
	done
done

