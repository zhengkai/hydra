#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")" && cd "$DIR" || exit 1

. ./config.sh

LOCK_FILE="${DIR}/lock/list"

exec 200>"$LOCK_FILE"
flock -x -n 200 || exit

git ls-remote --heads "$URL" | xargs -L 1 ./build.sh
