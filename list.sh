#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")" && cd "$DIR" || exit 1

. ./config.sh

export REPO_LOCAL="$DIR/repo"
export REPO_LOCK="$DIR/lock"
export REPO_URL="$URL"

git ls-remote --heads "$URL" | xargs -L 1 ./build.sh
