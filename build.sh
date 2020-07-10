#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")" && cd "$DIR" || exit 1

if [[ ! "$1" =~ ^[0-9a-f]{40}$ ]]; then
	>&2 echo 'hash error'
	exit 1
fi

if [[ "$2" != refs/heads/* ]]; then
	>&2 echo 'heads error'
	exit 1
fi

. ./config.sh

HASH="$1"
BRANCH=${2:11}
PORT=$(./get-port.sh "$BRANCH")

LOCK_FILE="${DIR}/lock/repo-${BRANCH}"

exec 200>"$LOCK_FILE"
flock -x -n 200 || exit

REPO="${DIR}/repo/${BRANCH}"

if [ ! -d "$REPO" ]; then
	git clone --depth 1 --single-branch --branch "$BRANCH" "$URL" "$REPO"
	HASH="new"
fi

cd "$REPO" || exit 1

HEAD=$(git rev-parse HEAD)
if [ "$HEAD" == "$HASH" ]; then
	>&2 echo "[ $BRANCH ] no change, skip"
	exit
fi

if [ "$HASH" != "new" ]; then
	git checkout ./
	git clean -df
	git pull --rebase
fi

echo "$BRANCH" "$PORT" "$REPO"
