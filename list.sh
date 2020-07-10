#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")" && cd "$DIR" || exit 1

. ./config.sh

git ls-remote --heads "$URL"
