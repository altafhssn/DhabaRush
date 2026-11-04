#!/bin/zsh
# Dhaba Rush: rebuilds the Google Play listing art from the real game.
#
#   docs/store/pipeline/make_store.sh                  # copy + capture + compose + icons (about 15 min)
#   docs/store/pipeline/make_store.sh --compose        # captions changed: recompose from WORK's frames
#   docs/store/pipeline/make_store.sh --icons          # icon set only
#   docs/store/pipeline/make_store.sh --install        # also copy the results into the repo
#
# Everything runs in a scratch copy of the project (WORK/game) with its own
# HOME per Godot instance, so the real save and the project are never touched.
# Nothing is exported, installed or uploaded.
#
# Outputs (WORK/final): shot1..8_{en,hi}.png 1440x2560, feature_graphic.png
# 1024x500, icon/ (android_{fg,bg,mono}.svg, app_icon.svg) and WORK/iconset
# (icon_512.png, icon_512_b.png, icon_1024.png, PNG layers).
# --install copies them to export/store/play/ and assets/icon/.
#
# Frame picks: "busy" moments save several frames; the script takes the one
# with the most seated travellers (earliest on a tie). Look at the contact
# sheets in WORK/final/contact_{en,hi}.png and swap a frame by hand if a
# floating sale number or an AD bubble covers something.
set -u
setopt null_glob

PIPE=${0:A:h}
REPO=${REPO:-${PIPE:h:h:h}}
WORK=${WORK:-${TMPDIR:-/tmp}/dhaba_store}
GODOT=${GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}
FONTS=$REPO/assets/fonts

DO_COPY=1; DO_CAPTURE=1; DO_COMPOSE=1; DO_ICONS=1; DO_INSTALL=0
for a in "$@"; do
  case "$a" in
    --compose) DO_COPY=0; DO_CAPTURE=0; DO_ICONS=0 ;;
    --icons) DO_CAPTURE=0; DO_COMPOSE=0 ;;
    --install) DO_INSTALL=1 ;;
    -h|--help) sed -n 2,22p "$0"; exit 0 ;;
    *) echo "unknown option $a" >&2; exit 2 ;;
  esac
done
[[ -x "$GODOT" ]] || { echo "Godot not found: $GODOT" >&2; exit 1; }
mkdir -p "$WORK/out" "$WORK/final/icon" "$WORK/logs"

# ---- the eight moments (flags for tools/store/store_rig.tscn) -------------------
MID="tandoor,galla,waiter,table,table,lassi,chai_hire,tandoor_hire,tandoor_lvl22,lassi_lvl8,waiter_up6,galla_up6,claim"
PRE="tandoor,galla,waiter,table,table,chai_hire,tandoor_hire,chai_lvl20,tandoor_lvl18,waiter_up6,galla_up6,claim"
LATE="tandoor,galla,waiter,waiter,table,table,table,lassi,kadai,chai_hire,chai_hire,tandoor_hire,tandoor_hire,lassi_hire,kadai_hire,chai_lvl52,tandoor_lvl40,lassi_lvl27,kadai_lvl14,waiter_up12,galla_up12,claim"
typeset -A FLAGS PICK
FLAGS[1]="--no-notes --arrivals=19 --prep=$LATE --show-cash=9800 --cam=4.0,4.2,1.2 --scene=busy --wait=45 --span=100 --min-seats=6 --gap=4 --max-frames=10"
FLAGS[2]="--no-notes --prep=$MID --show-cash=2600 --scene=unlock"
FLAGS[3]="--no-notes --time=0.575 --arrivals=19 --prep=$LATE --show-cash=9800 --cam=3.2,5.6,1.12 --scene=busy --wait=38 --span=50 --min-seats=5 --gap=3 --max-frames=12"
FLAGS[4]="--no-notes --prep=$MID --show-cash=2600 --scene=staff --tab=waiters"
FLAGS[5]="--no-notes --prep=${LATE/kadai_lvl14/kadai_lvl50} --show-cash=9800 --scene=sheet --sheet=kadai"
FLAGS[6]="--no-notes --prep=$MID,waiter --show-cash=2600 --scene=build --scroll=280"
FLAGS[7]="--notes-after-prep --prep=$PRE --show-cash=3600 --scene=note --note=menu_lassi --type=5"
FLAGS[8]="--no-notes --prep=$MID --show-cash=2600 --scene=offline"
PICK[1]="busy"; PICK[2]="unlock.png"; PICK[3]="busy"; PICK[4]="staff_waiters.png"
PICK[5]="sheet_kadai.png"; PICK[6]="build_s280.png"; PICK[7]="note_menu_lassi.png"; PICK[8]="offline.png"
# Captions: [h]..[/h] = marigold highlight, \n = line break (docs/store/play-listing.md §4).
# 2026-11-02 (core and feel C9.1 / C9.3): captions 3 and 8 reworded (the player is never
# the server; no earnings words). Keep them equal to the play-listing.md §4 table.
typeset -A CAP_EN CAP_HI
CAP_EN[1]='Run your own\n[h]highway dhaba[/h]';        CAP_HI[1]='अपना [h]हाईवे ढाबा[/h]\nखुद चलाएँ'
CAP_EN[2]='Level up to unlock\n[h]new dishes[/h]';      CAP_HI[2]='लेवल बढ़ाएँ,\n[h]नए पकवान[/h] खोलें'
CAP_EN[3]='Your dhaba, open\n[h]day and night[/h]';     CAP_HI[3]='आपका ढाबा खुला\n[h]दिन-रात[/h]'
CAP_EN[4]='Hire [h]waiters, cooks[/h]\nand cashiers';   CAP_HI[4]='[h]वेटर, कुक[/h] और\nकैशियर रखें'
CAP_EN[5]='[h]16 dishes[/h], from chai\nto kadai paneer'; CAP_HI[5]='[h]16 पकवान[/h], चाय से\nकड़ाही पनीर तक'
CAP_EN[6]='Build the tandoor,\n[h]lassi and kadai[/h]';  CAP_HI[6]='तंदूर, [h]लस्सी और कड़ाही[/h]\nकाउंटर बनाएँ'
CAP_EN[7]='[h]Munshi-ji[/h] shows\nyou what to do';      CAP_HI[7]='[h]मुंशी जी[/h] बताएँगे\nआगे क्या करना है'
CAP_EN[8]="Your staff work\n[h]while you're away[/h]";   CAP_HI[8]='आप न हों, तब भी\n[h]स्टाफ़ काम करता है[/h]'

# One rig run: rig <slot> <outdir> <flags...>
rig() {
  local slot=$1 out=$2; shift 2
  mkdir -p "$WORK/out/$out" "$WORK/home_$slot"
  HOME="$WORK/home_$slot" "$GODOT" --path "$WORK/game" res://tools/store/store_rig.tscn --resolution 360x540 --position 0,0 -- \
      --gfx=high --seed=7 --out="$WORK/out/$out" "$@" > "$WORK/logs/${out//\//_}.log" 2>&1
  echo "  captured $out ($(ls "$WORK/out/$out" | grep -c png) frames)"
}
munshi() {
  HOME="$WORK/home_m" "$GODOT" --path "$WORK/game" -s res://tools/store/munshi_render.gd --resolution 300x300 -- "$@" \
      > "$WORK/logs/munshi.log" 2>&1
}

# ---- 1. scratch copy ------------------------------------------------------------
if (( DO_COPY )); then
  echo "1. scratch copy -> $WORK/game"
  rsync -a --delete --exclude android --exclude export --exclude keystore --exclude .git \
      --exclude config/monetization.local.cfg "$REPO/" "$WORK/game/"
  mkdir -p "$WORK/game/tools/store"
  cp "$PIPE"/rig/store_rig.gd "$PIPE"/rig/store_rig.tscn "$PIPE"/rig/munshi_render.gd "$WORK/game/tools/store/"
fi
# The compositor projects run from WORK too (Godot may write a .godot cache into a project folder).
mkdir -p "$WORK/tools"
rsync -a "$PIPE/compose" "$PIPE/montage" "$WORK/tools/"
COMPOSE="$WORK/tools/compose"
MONTAGE="$WORK/tools/montage"

# ---- 2. capture -----------------------------------------------------------------
if (( DO_CAPTURE )); then
  echo "2. capture (Godot windows pop up; leave them alone)"
  for L in en hi; do
    for batch in "1 2 3 4" "5 6 7 8"; do
      for n in ${=batch}; do
        rm -rf "$WORK/out/$L/$n"
        rig "$L$n" "$L/$n" --fresh --skip-tutorial --lang=$L ${=FLAGS[$n]} &
        sleep 3
      done
      wait
    done
  done
  echo "   feature plate + Munshi-ji renders"
  rm -rf "$WORK/out/feature"
  rig feat feature --fresh --skip-tutorial --no-notes --hud=off --size=2048x1000 --time=0.57 --arrivals=19 \
      --prep=$LATE --scene=views --views="3.8:9.5:0.95" --wait=28
  munshi --out="$WORK/out/bust_idle.png" --pose=idle --win=-0.6,0.6,0.3,1.5 --yaw=-0.10 --ppm=1700
  munshi --out="$WORK/out/bust_namaste.png" --pose=namaste --win=-0.75,0.75,0.0,1.6 --yaw=-0.12 --ppm=900
fi

# ---- 3. compose -----------------------------------------------------------------
pick() {  # pick <dir> <name|busy> -> path
  local dir=$1 what=$2
  if [[ $what != busy ]]; then echo "$dir/$what"; return; fi
  ls "$dir" | grep '^busy_.*_s[0-9]*\.png$' | sort -t_ -k3,3r -k2,2 | head -1 | sed "s#^#$dir/#"
}
if (( DO_COMPOSE )); then
  echo "3. compose"
  JOB="$WORK/final/job.json"
  {
    echo '{"shots": ['
    first=1
    for L in en hi; do
      for n in 1 2 3 4 5 6 7 8; do
        src=$(pick "$WORK/out/$L/$n" "${PICK[$n]}")
        [[ -f "$src" ]] || { echo "  missing frame for $L shot $n" >&2; continue; }
        cap="${CAP_EN[$n]}"; [[ $L == hi ]] && cap="${CAP_HI[$n]}"
        (( first )) || echo ','
        first=0
        /usr/bin/python3 -c 'import json,sys; print(json.dumps({"src": sys.argv[1], "out": sys.argv[2], "caption": sys.argv[3].replace("\\n", "\n")}, ensure_ascii=False))' \
            "$src" "$WORK/final/shot${n}_$L.png" "$cap"
      done
    done
    echo '],'
    plate=$(ls "$WORK"/out/feature/view0_*.png | head -1)
    printf '"feature": {"src": "%s", "munshi": "%s", "out": "%s", "title": "Dhaba Rush", "subtitle": "Highway Idle Tycoon", "munshi_scale": 0.92, "munshi_dx": -40, "munshi_dy": 40}}\n' \
        "$plate" "$WORK/out/bust_namaste.png" "$WORK/final/feature_graphic.png"
  } > "$JOB"
  HOME="$WORK/home_c" "$GODOT" --path "$COMPOSE" -s shot_compose.gd --resolution 300x300 -- \
      --job="$JOB" --fonts="$FONTS" > "$WORK/logs/compose.log" 2>&1
  grep -c '^\[compose\] /' "$WORK/logs/compose.log" | sed 's/^/   images written: /'
  for L in en hi; do
    HOME="$WORK/home_c" "$GODOT" --headless --path "$MONTAGE" -s montage.gd -- \
        --out="$WORK/final/contact_$L.png" --w=360 --cols=4 "$WORK"/final/shot?_$L.png > /dev/null 2>&1
  done
fi

# ---- 4. icons -------------------------------------------------------------------
if (( DO_ICONS )); then
  echo "4. icons"
  [[ -f "$WORK/out/bust_idle.png" ]] || munshi --out="$WORK/out/bust_idle.png" --pose=idle --win=-0.6,0.6,0.3,1.5 --yaw=-0.10 --ppm=1700
  HOME="$WORK/home_c" "$GODOT" --path "$COMPOSE" -s icon_compose.gd --resolution 300x300 -- \
      --src="$WORK/out" --out="$WORK/iconset" > "$WORK/logs/icons.log" 2>&1
  /usr/bin/python3 "$PIPE/wrap_icons.py" "$WORK/iconset" "$WORK/final/icon"
  HOME="$WORK/home_c" "$GODOT" --headless --path "$MONTAGE" -s icon_preview.gd -- \
      --set="$WORK/iconset" --out="$WORK/final/icon_readability.png" > /dev/null 2>&1
fi

# ---- 5. install -----------------------------------------------------------------
if (( DO_INSTALL )); then
  echo "5. install into $REPO"
  P="$REPO/export/store/play"
  mkdir -p "$P/raw"
  cp "$WORK"/final/shot?_en.png "$WORK"/final/shot?_hi.png "$WORK/final/feature_graphic.png" "$P/"
  cp "$WORK/iconset/icon_512.png" "$WORK/iconset/icon_512_b.png" "$P/"
  cp "$WORK/iconset/icon_1024.png" "$P/icon_1024_master.png"
  cp "$WORK"/final/icon/*.svg "$REPO/assets/icon/"
fi
echo "Done: $WORK/final"
