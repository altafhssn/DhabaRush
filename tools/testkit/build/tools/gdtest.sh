#!/bin/bash
# Run a SceneTree test script headless inside a QA slot (never the real project).
# Usage: gdtest.sh SLOT TEST.gd LOG [LIMIT_S] [-- extra user args]
# The script is copied into the slot as res://_qa_test.gd; it must extend SceneTree (or MainLoop),
# print its own PASS/FAIL lines and call quit(<fails>). Autoloads (Game, Ads, Iap, ...) are live; there is no
# main scene: a world test calls change_scene_to_file("res://scenes/main3.tscn") and waits for Refs.sim.
# Game flags (--fresh, --skip-tutorial, ...) go after --; main3 reads them as usual. Real time (no --fixed-fps).
Q=${DR_WORK:-$HOME/DhabaRushQA}/qa
. "$Q/sem.sh"
SLOT="$1"; T="$2"; LOG="$3"; shift 3; LIMIT=300
if [[ "$1" =~ ^[0-9]+$ ]]; then LIMIT="$1"; shift; fi
[ "$1" = "--" ] && shift
[ -d "$Q/slots/$SLOT/proj" ] || { echo "no slot $SLOT"; exit 2; }
cp "$T" "$Q/slots/$SLOT/proj/_qa_test.gd"
mkdir -p "$(dirname "$LOG")"
cd "$Q/slots/$SLOT" || exit 2
sem_acquire godot "${GODOT_SLOTS:-4}"
HOME="$Q/slots/$SLOT/home" perl -e 'alarm shift; exec @ARGV' "$LIMIT" \
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path proj -s res://_qa_test.gd -- "$@" > "$LOG" 2>&1
RC=$?; sem_release; echo "rc=$RC" >> "$LOG"; exit $RC
