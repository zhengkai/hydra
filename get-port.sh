#!/bin/bash -e

PORT_STEP=20

DIR="$(dirname "$(readlink -f "$0")")" && cd "$DIR" || exit 1

BRANCH="${1/\//-}"

if [ -z "$BRANCH" ]; then
	>&2 echo no branch input
	exit 1
fi

cd port || exit 1

LOCK_FILE="${DIR}/lock/port"

FILE="br-${BRANCH}"
PORT=$(cat "$FILE" 2>/dev/null || :)
if [ -n "$PORT" ]; then
	echo "$PORT" | cut -d' ' -f1
	exit
fi

exec 200>"$LOCK_FILE"
flock 200 || exit

LAST_FILE="last"
LAST_PORT=$(cat "$LAST_FILE" 2>/dev/null || :)
((LAST_PORT+=0)) || :

if [ "$LAST_PORT" -lt 10000 ]; then
	LAST_PORT=50000
fi

while true; do
	((LAST_PORT+=PORT_STEP))
	FOUND=$(grep "$LAST_PORT" --include="branch-*" ./* 2>/dev/null || :)
	if [ -z "$FOUND" ]; then
		PORT="$LAST_PORT"
		break
	fi
done

echo "$PORT"
echo "$LAST_PORT" > "$LAST_FILE"
echo "$PORT $1" > "$FILE"
