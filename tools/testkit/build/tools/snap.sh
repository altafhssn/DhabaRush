#!/bin/bash
# Snapshot the real project for a wave, once (APFS clone). Usage: snap.sh WAVE   (1, 2, 3, 3b)
# Idempotent: the first caller makes $B/snap/wave<WAVE>; later callers return at once (or wait for it).
B=${DR_WORK:-$HOME/DhabaRushQA}/build
R=/Users/almeer/Documents/HighwayDhaba
W="$1"; [ -n "$W" ] || { echo "usage: snap.sh WAVE"; exit 2; }
SNAP="$B/snap/wave$W"
[ -f "$SNAP/.done" ] && { echo "snapshot wave$W exists ($(cat "$SNAP/.done"))"; exit 0; }
if mkdir "$SNAP.lock" 2>/dev/null; then
  rm -rf "$SNAP"; cp -cRp "$R" "$SNAP" && date "+%F %T" > "$SNAP/.done"
  echo "snapshot wave$W made"; exit 0
fi
for i in $(seq 1 600); do [ -f "$SNAP/.done" ] && { echo "snapshot wave$W ready"; exit 0; }; sleep 1; done
echo "snapshot wave$W: timed out waiting"; exit 1
