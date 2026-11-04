#!/bin/bash
# Windowed screenshot capture of the current game for the UI / feel redesign (owner approved, 3 Nov).
# Runs in slot uxcap only (own HOME and user dir); never the real project or save.
# Usage: uxcap.sh [ONLY_NAME]
Q="$(cd "$(dirname "$0")" && pwd)"
SLOT="$Q/slots/uxcap"
OUT="$SLOT/shots"
ONLY="$1"
MID="waiter,waiter,tandoor,lassi,table,chai_lvl30,tandoor_lvl26,lassi_lvl12"
FULL="waiter,waiter,tandoor,lassi,kadai,table,table,table,chai_lvl60,tandoor_lvl55,lassi_lvl52,kadai_lvl30"
SHEET="waiter,waiter,tandoor,lassi,kadai,chai_lvl12,tandoor_lvl26,lassi_lvl5,kadai_lvl51"

seq_shots() { # start step end
  python3 -I -c "import sys; a,b,c=map(float,sys.argv[1:]); x=a; r=[]
while x<=c+1e-9: r.append('%g'%x); x+=b
print(','.join(r))" "$1" "$2" "$3"
}

cap() { # NAME LIMIT_S args...
  local name="$1" limit="$2"; shift 2
  [ -n "$ONLY" ] && [ "$ONLY" != "$name" ] && return 0
  local d="$OUT/$name"; rm -rf "$d"; mkdir -p "$d"
  local nn="--no-notes"; case "$name" in walk*) nn="";; esac
  echo "[uxcap] $name: $*"
  ( cd "$SLOT" && HOME="$SLOT/home" perl -e 'alarm shift; exec @ARGV' "$limit" \
      /Applications/Godot.app/Contents/MacOS/Godot --path proj --resolution 720x1280 -- "$@" $nn --shot-dir="$d" \
      > "$d/log.txt" 2>&1 )
  echo "[uxcap] $name rc=$? shots=$(ls "$d"/*.png 2>/dev/null | wc -l | tr -d ' ') errors=$(grep -c 'SCRIPT ERROR' "$d/log.txt")"
}

WALK="$(seq_shots 1 3 180),$(seq_shots 195 15 780)"
cap walk 900 --fresh --auto --seed=1 --consent=ask --speed=2 --stats=60 --shots="$WALK" --quit-at=785
cap walk_free 900 --fresh --auto --seed=1 --consent=ask --speed=2 --stats=60 --shots="$(seq_shots 185 15 780)" --quit-at=785

cap home_early 60 --fresh --skip-tutorial --money=300 --shots=3,10 --quit-at=11
cap home_mid 60 --fresh --skip-tutorial --money=2000 --buy="$MID" --time=0.3 --shots=4,12,20 --quit-at=21
cap home_full 60 --fresh --skip-tutorial --money=20000 --buy="$FULL" --signboard=1 --claims=25 --time=0.3 --shots=4,12,20 --quit-at=21
cap night 60 --fresh --skip-tutorial --money=3000 --buy="$MID" --time=0.84 --shots=4,8 --quit-at=9

for st in chai tandoor lassi kadai; do
  cap "sheet_$st" 60 --fresh --skip-tutorial --money=3000 --buy="$SHEET" --open="$st" --shots=2.5 --quit-at=3
done
for p in staff:waiters staff:cashiers staff:cooks build stats tables quick:waiters quick:tables settings; do
  cap "panel_${p/:/_}" 60 --fresh --skip-tutorial --money=3000 --buy="$MID" --open="$p" --shots=2.5 --quit-at=3
done
cap panel_build_full 60 --fresh --skip-tutorial --money=20000 --buy="$FULL" --open=build --shots=2.5 --quit-at=3
cap panel_stats_full 60 --fresh --skip-tutorial --money=20000 --buy="$FULL" --open=stats --shots=2.5 --quit-at=3
cap panel_vip 60 --fresh --skip-tutorial --money=3000 --buy="$MID" --sessions=3 --open=vip --shots=2.5 --quit-at=3
cap panel_vip_first 60 --fresh --skip-tutorial --money=3000 --buy="$MID" --sessions=1 --open=vip --shots=2.5 --quit-at=3
cap reno_ready 60 --fresh --skip-tutorial --money=150000 --reno-ready --open=build --shots=2.5,5 --quit-at=6
cap family 90 --fresh --skip-tutorial --money=20000 --renovate --shots=4,10 --quit-at=11
cap nh48 120 --fresh --skip-tutorial --money=20000 --move=nh48 --shots=4,10 --quit-at=11
cap baraat 90 --fresh --skip-tutorial --money=5000 --buy="$MID" --event=on --event-guests=12 --shots=3,8,16,24 --quit-at=25
cap special 60 --fresh --skip-tutorial --money=3000 --buy="$MID" --date=2026-11-04 --special=auto --shots=1,2,3.5,6 --quit-at=7
cap offline_prep 60 --fresh --skip-tutorial --money=3000 --buy="$MID" --shots=4 --quit-at=5
cap offline 60 --away=7200 --shots=1.5,3,6 --quit-at=7
cap hindi_home 60 --lang=hi --fresh --skip-tutorial --money=2000 --buy="$MID" --time=0.3 --shots=4 --quit-at=5
cap hindi_sheet 60 --lang=hi --fresh --skip-tutorial --money=3000 --buy="$SHEET" --open=chai --shots=2.5 --quit-at=3
cap capture_menu 240 --fresh --skip-tutorial --money=1e9 --capture=menu
cap capture_free 240 --fresh --skip-tutorial --money=1e6 --capture=free
echo "[uxcap] all done: $(find "$OUT" -name '*.png' | wc -l | tr -d ' ') shots"
