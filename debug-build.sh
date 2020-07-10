#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")" && cd "$DIR" || exit 1

./build.sh ffffffffffffffffffffffffffffffffffffffff refs/heads/master
