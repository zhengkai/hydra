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

HASH="$1"
BRANCH=${2:11}

echo "$HASH" "$BRANCH"

LOCK_FILE="${REPO_LOCK}/${BRANCH}"

exec 200>"$LOCK_FILE"
flock -x -n 200 || exit

cd "$REPO_LOCAL" || exit

if [ ! -d "$BRANCH" ]; then
	git clone  --single-branch --branch "$BRANCH" "$REPO_URL" "$BRANCH"
	HASH="new"
fi

cd "$BRANCH" || exit 1

echo "$HEAD" "$HASH"

HEAD=$(git rev-parse HEAD)
if [ "$HEAD" == "$HASH" ]; then
	>&2 echo no change, skip
	exit
fi

if [ "$HASH" != "new" ]; then
	git checkout ./
	git clean -df
	git pull --rebase
fi
