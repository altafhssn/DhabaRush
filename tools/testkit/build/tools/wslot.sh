#!/bin/bash
# Make or refresh QA slot SLOT from the wave snapshot plus only the listed paths from the real project.
# Usage: wslot.sh SLOT WAVE path...   (paths relative to the project; files or folders; missing ones are skipped)
# Run $Q/import.sh SLOT once per new slot and after adding .glb/.png/.wav files or a new class_name.
Q=${DR_WORK:-$HOME/DhabaRushQA}/qa
B=${DR_WORK:-$HOME/DhabaRushQA}/build
R=/Users/almeer/Documents/HighwayDhaba
SLOT="$1"; W="$2"; shift 2
SNAP="$B/snap/wave$W"
[ -f "$SNAP/.done" ] || { echo "no snapshot wave$W (run $B/tools/snap.sh $W)"; exit 2; }
"$Q/mkslot.sh" "$SLOT" "$SNAP" || exit 1
D="$Q/slots/$SLOT/proj"
for p in "$@"; do
  p="${p#./}"
  if [ -e "$R/$p" ]; then mkdir -p "$(dirname "$D/$p")"; rm -rf "$D/$p"; cp -Rp "$R/$p" "$D/$p"; echo "  + $p"
  else echo "  (not in project yet: $p)"; fi
done
