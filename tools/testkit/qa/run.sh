#!/bin/bash
# Run the game headless in a slot. Usage: run.sh SLOT LOG [SECONDS_LIMIT] -- game args...
# Uses --fixed-fps 60 (deterministic game time; FIXED= disables it) and HOME=<slot>/home (never the real save).
# At most GODOT_SLOTS (default 4) Godot processes run at once machine-wide; the time limit starts after the wait.
Q="$(cd "$(dirname "$0")" && pwd)"
. "$Q/sem.sh"
SLOT="$1"; LOG="$2"; LIMIT=900; shift 2
if [ "$1" != "--" ]; then LIMIT="$1"; shift; fi
[ "$1" = "--" ] && shift
mkdir -p "$(dirname "$LOG")"
LOG="$(cd "$(dirname "$LOG")" && pwd)/$(basename "$LOG")"
cd "$Q/slots/$SLOT" || exit 2
sem_acquire godot "${GODOT_SLOTS:-4}"
HOME="$Q/slots/$SLOT/home" perl -e 'alarm shift; exec @ARGV' "$LIMIT" \
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path proj ${FIXED---fixed-fps 60} -- "$@" > "$LOG" 2>&1
RC=$?
sem_release
echo "rc=$RC" >> "$LOG"
exit $RC
