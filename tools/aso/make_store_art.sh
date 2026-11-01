#!/bin/zsh
# Store screenshots + Play feature graphic for docs/aso.md §6.
#
#   tools/aso/make_store_art.sh                 # everything (about 4 minutes)
#   tools/aso/make_store_art.sh --only=1,4      # recapture + recompose shots 1 and 4
#   tools/aso/make_store_art.sh --compose-only  # new captions on the existing raw frames
#   tools/aso/make_store_art.sh --feature-only  # just the 1024x500 feature graphic
#
# Stage 1 (capture) runs the game inside tools/aso/shot_rig.tscn, a SubViewport
# of the exact frame size (the HUD lays out as on a phone of that aspect), with
# the debug flags listed in SHOT_FLAGS below, and saves the frame at the game
# time in SHOT_TIME (plus the alternates in SHOT_ALTS, kept for hand-picking).
# Stage 2 (compose) runs tools/aso/compose (a tiny separate Godot project) to
# put the Baloo 2 caption band on top and write the final PNGs:
#   export/store/appstore/shotN_en.png  1320x2868  (App Store 6.9")
#   export/store/play/shotN_en.png      1080x1920  (Google Play)
#   …and shotN_hi.png with the Hindi captions, plus
#   export/store/play/feature_graphic.png  1024x500
# Raw frames: export/store/raw/<profile>/shotN/t0TT.T.png, the picked one copied
# to export/store/raw/<profile>/shotN.png. Logs: export/store/raw/logs/.
#
# The game's save (user://save3.json) is backed up before the run and restored
# afterwards; every shot starts from --fresh.
set -u
setopt null_glob

ROOT="${0:A:h:h:h}"
GODOT="${GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"
OUT="$ROOT/export/store"
RAW="$OUT/raw"
SAVE_DIR="$HOME/Library/Application Support/Godot/app_userdata/Dhaba Rush"
SEED=7
MONEY=3000          # reference units; the HUD shows x10 = ₹30,000

# ---- the seven shots (docs/aso.md §6) ---------------------------------------
typeset -A SHOT_FLAGS SHOT_TIME SHOT_ALTS CAP_EN CAP_HI SHOT_NOTE
# Flags after the common ones (see capture_shot). --cam=x,z,zoom, --light,
# --away and --hud are read by shot_rig.gd; the rest by scripts/v3/main3.gd.
SHOT_FLAGS[1]="--skip-tutorial --money=$MONEY --arrivals=40 --speed=2 --light=night --cam=3.6,12.0,1.5"
SHOT_TIME[1]=70;  SHOT_ALTS[1]="60,80,90"
CAP_EN[1]="Run India's busiest highway dhaba"
CAP_HI[1]="इंडिया का सबसे बिज़ी हाईवे ढाबा चलाओ"
SHOT_NOTE[1]="Night relight is capture-only (shot_rig --light=night); the game has no day/night cycle yet. Wide view: lit gate and queue at the top, the highway and the lay-by with parked lorries below. Which lorries are on the road at t=70 varies run to run: pick from the alternates if the road is empty. Cash bursts happen at the gallas, which this framing leaves out; --cam=3.4,8.6,1.3 is the interior alternative."

SHOT_FLAGS[2]="--skip-tutorial --money=$MONEY --cam=1.6,1.75,0.7"
SHOT_TIME[2]=10;  SHOT_ALTS[2]="8,12,14"
CAP_EN[2]="Pour kadak chai, serve hot parathas"
CAP_HI[2]="कड़क चाय बनाओ, गरम पराठे परोसो"
SHOT_NOTE[2]="Pinky brewing at the chai counter with the radial timer."

SHOT_FLAGS[3]="--skip-tutorial --money=$MONEY --buy=tandoor --cam=6.9,2.1,0.8"
SHOT_TIME[3]=9;   SHOT_ALTS[3]="6,12,15"
CAP_EN[3]="Build the tandoor and grow"
CAP_HI[3]="तंदूर बनाओ, ढाबा बढ़ाओ"
SHOT_NOTE[3]="DEVIATION: the spec says 'tandoor build FX', but v0.3 has no world reveal FX for a build (spec J18 is a ring on the Daftar row only). This is the freshly built tandoor in service (--buy=tandoor at t=0.5). Alternative: the Daftar BUILD tab (--open=daftar, t=2)."

SHOT_FLAGS[4]="--skip-tutorial --money=$MONEY --arrivals=40 --speed=2 --cam=14,15.4,1.15"
SHOT_TIME[4]=50;  SHOT_ALTS[4]="35,65,80,95"
CAP_EN[4]="Trucks, buses, bikes, all stop here"
CAP_HI[4]="ट्रक, बस, बाइक, सब यहीं रुकते हैं"
SHOT_NOTE[4]="Bus stop + lay-by view. A bus is at the stop around t=50 and t=95 with seed $SEED; traffic timing drifts a little between runs, so check the alternates."

SHOT_FLAGS[5]="--skip-tutorial --money=$MONEY --away=7200"
SHOT_TIME[5]=2;   SHOT_ALTS[5]=""
CAP_EN[5]="Earn even while you're away"
CAP_HI[5]="दूर रहो तब भी कमाई"
SHOT_NOTE[5]="Offline popup via shot_rig --away=7200 (2 h, the cap)."

SHOT_FLAGS[6]="--skip-tutorial --money=$MONEY --open=chai"
SHOT_TIME[6]=2;   SHOT_ALTS[6]=""
CAP_EN[6]="Hire staff, upgrade everything"
CAP_HI[6]="स्टाफ़ रखो, सब अपग्रेड करो"
SHOT_NOTE[6]="Chai counter station sheet (STAFF / LEVEL UP / SPEED)."

SHOT_FLAGS[7]="--tutorial"
SHOT_TIME[7]=6.5; SHOT_ALTS[7]="4.5,9"
CAP_EN[7]="Munshi-ji keeps the books"
CAP_HI[7]="हिसाब मुंशी-जी के हाथ"
SHOT_NOTE[7]="Tutorial line 1 (fresh save, no --skip-tutorial); the box waits for a tap, so any time after ~5 s shows the full line."

# Feature graphic: dusk relight, HUD hidden, three lorries in the lay-by.
FEATURE_FLAGS="--skip-tutorial --money=$MONEY --arrivals=40 --speed=2 --light=dusk --hud=off --cam=3.8,10.8,0.95"
FEATURE_TIME=75; FEATURE_ALTS="60,90"
FEATURE_TITLE="Dhaba Rush"
FEATURE_SUBTITLE="Highway Idle Tycoon"

# ---- output profiles ---------------------------------------------------------
# name  final WxH  caption band height  -> frame = W x (H - band)
typeset -A PROFILE_W PROFILE_H PROFILE_BAND
PROFILE_W[appstore]=1320; PROFILE_H[appstore]=2868; PROFILE_BAND[appstore]=440
PROFILE_W[play]=1080;     PROFILE_H[play]=1920;     PROFILE_BAND[play]=300
PROFILES=(appstore play)

# ---- options -----------------------------------------------------------------
ONLY=""; DO_CAPTURE=1; DO_COMPOSE=1; DO_SHOTS=1; DO_FEATURE=1
for a in "$@"; do
  case "$a" in
    --only=*) ONLY="${a#--only=}" ;;
    --compose-only) DO_CAPTURE=0 ;;
    --capture-only) DO_COMPOSE=0 ;;
    --feature-only) DO_SHOTS=0 ;;
    --no-feature) DO_FEATURE=0 ;;
    -h|--help) sed -n 2,30p "$0"; exit 0 ;;
    *) echo "unknown option $a" >&2; exit 2 ;;
  esac
done
want_shot() { [[ -z "$ONLY" || ",$ONLY," == *",$1,"* ]]; }

[[ -x "$GODOT" ]] || { echo "Godot not found at $GODOT (set GODOT=)" >&2; exit 1; }
mkdir -p "$RAW/logs" "$OUT/appstore" "$OUT/play"

# ---- save backup ---------------------------------------------------------------
BACKUP="$(mktemp -d)"
restore_save() {
  for f in save3.json save.json; do
    if [[ -f "$BACKUP/$f" ]]; then cp "$BACKUP/$f" "$SAVE_DIR/$f"
    elif [[ -f "$SAVE_DIR/$f" && -f "$BACKUP/.had_none_$f" ]]; then rm -f "$SAVE_DIR/$f"; fi
  done
  rm -rf "$BACKUP"
}
if (( DO_CAPTURE )); then
  mkdir -p "$SAVE_DIR"
  for f in save3.json save.json; do
    if [[ -f "$SAVE_DIR/$f" ]]; then cp "$SAVE_DIR/$f" "$BACKUP/$f"; else touch "$BACKUP/.had_none_$f"; fi
  done
  trap restore_save EXIT INT TERM
fi

# ---- stage 1: capture ----------------------------------------------------------
# capture <dir> <WxH> <pick-time> <alt-times> <flags...>
capture() {
  local dir="$1" size="$2" pick="$3" alts="$4"; shift 4
  local times="$pick"; [[ -n "$alts" ]] && times="$pick,$alts"
  local last="$pick"
  for t in ${(s:,:)times}; do (( t > last )) && last=$t; done
  local quit; quit=$(printf "%.1f" $(( last + 1.0 )))
  local fresh=(--fresh --seed=$SEED)
  local extra=("$@")
  # "--tutorial" = run the tutorial (no --skip-tutorial); it is only a marker here.
  extra=(${extra:#--tutorial})
  rm -rf "$dir" "$dir.png"
  local log="$RAW/logs/$(basename "$(dirname "$dir")")_$(basename "$dir").log"
  local got; got=$(printf "t%05.1f.png" "$pick")
  local attempt
  for attempt in 1 2; do
    mkdir -p "$dir"
    "$GODOT" --path "$ROOT" res://tools/aso/shot_rig.tscn --resolution 405x720 --position 0,0 -- \
        "${fresh[@]}" "${extra[@]}" --size="$size" --shots="$times" --quit-at="$quit" --shot-dir="$dir" \
        > "$log" 2>&1
    if [[ -f "$dir/$got" ]]; then
      cp "$dir/$got" "$dir.png"
      echo "  captured $(basename "$(dirname "$dir")")/$(basename "$dir") t=$pick ($size)"
      return 0
    fi
    # A Godot instance occasionally dies mid-run when several run at once: retry once.
    echo "  retrying $(basename "$(dirname "$dir")")/$(basename "$dir") (no $got after attempt $attempt)" >&2
    cp "$log" "$log.attempt$attempt"
  done
  echo "  FAILED   $dir t=$pick — see $log" >&2
  return 1
}

FAILED=0
if (( DO_CAPTURE )); then
  echo "Stage 1: capture (Godot windows will pop up; leave them alone)"
  if (( DO_SHOTS )); then
    for n in 1 2 3 4 5 6 7; do
      want_shot $n || continue
      pids=()
      for p in $PROFILES; do
        frame_w=${PROFILE_W[$p]}; frame_h=$(( ${PROFILE_H[$p]} - ${PROFILE_BAND[$p]} ))
        capture "$RAW/$p/shot$n" "${frame_w}x${frame_h}" "${SHOT_TIME[$n]}" "${SHOT_ALTS[$n]}" ${=SHOT_FLAGS[$n]} &
        pids+=($!)
        sleep 2   # let the first instance finish wiping/loading the save
      done
      for pid in $pids; do wait $pid || FAILED=1; done
    done
  fi
  if (( DO_FEATURE )) && ( [[ -z "$ONLY" ]] || want_shot feature ); then
    capture "$RAW/feature/feature" "2048x1000" "$FEATURE_TIME" "$FEATURE_ALTS" ${=FEATURE_FLAGS} || FAILED=1
  fi
fi

# ---- stage 2: compose ----------------------------------------------------------
json_str() { local s="$1"; s="${s//\\/\\\\}"; s="${s//\"/\\\"}"; printf '"%s"' "$s"; }

if (( DO_COMPOSE )); then
  echo "Stage 2: compose"
  JOB="$RAW/job.json"
  {
    echo '{"shots": ['
    first=1
    if (( DO_SHOTS )); then
      for n in 1 2 3 4 5 6 7; do
        want_shot $n || continue
        for p in $PROFILES; do
          src="$RAW/$p/shot$n.png"
          [[ -f "$src" ]] || { echo "  missing $src (capture first)" >&2; FAILED=1; continue; }
          for lang in en hi; do
            cap="${CAP_EN[$n]}"; [[ $lang == hi ]] && cap="${CAP_HI[$n]}"
            (( first )) || echo ','
            first=0
            printf '{"src": %s, "out": %s, "w": %d, "h": %d, "band": %d, "caption": %s}' \
              "$(json_str "$src")" "$(json_str "$OUT/$p/shot${n}_$lang.png")" \
              "${PROFILE_W[$p]}" "${PROFILE_H[$p]}" "${PROFILE_BAND[$p]}" "$(json_str "$cap")"
          done
        done
      done
    fi
    echo ']'
    if (( DO_FEATURE )) && [[ -f "$RAW/feature/feature.png" ]] && ( [[ -z "$ONLY" ]] || want_shot feature ); then
      printf ', "feature": {"src": %s, "out": %s, "w": 1024, "h": 500, "title": %s, "subtitle": %s}\n' \
        "$(json_str "$RAW/feature/feature.png")" "$(json_str "$OUT/play/feature_graphic.png")" \
        "$(json_str "$FEATURE_TITLE")" "$(json_str "$FEATURE_SUBTITLE")"
    fi
    echo '}'
  } > "$JOB"
  "$GODOT" --path "$ROOT/tools/aso/compose" -s compose.gd --resolution 400x300 --position 0,0 -- --job="$JOB" \
      > "$RAW/logs/compose.log" 2>&1 || FAILED=1
  grep "^\[compose\]" "$RAW/logs/compose.log" | sed 's/^/  /'
fi

# ---- notes / placeholder list -------------------------------------------------
if (( DO_COMPOSE && DO_SHOTS )) && [[ -z "$ONLY" ]]; then
  {
    echo "# export/store — generated by tools/aso/make_store_art.sh on $(date '+%Y-%m-%d %H:%M')"
    echo
    echo "Captions and shot list: docs/aso.md §6. Final PNGs: appstore/ (1320x2868), play/ (1080x1920), play/feature_graphic.png (1024x500)."
    echo "Raw frames in raw/<profile>/shotN/ (all times), raw/<profile>/shotN.png (the picked one)."
    echo
    echo "## Placeholders (shots the current build cannot show)"
    echo
    echo "None: every shot in §6 is captured from the running v0.3 build. Deviations from the shot descriptions:"
    echo
    for n in 1 2 3 4 5 6 7; do
      echo "- Shot $n (${CAP_EN[$n]}): ${SHOT_NOTE[$n]}"
    done
    echo "- Feature graphic: dusk relight is capture-only (--light=dusk); title set as two lines, \"$FEATURE_TITLE\" / \"$FEATURE_SUBTITLE\" (the store-name colon is dropped in the lockup; change FEATURE_TITLE in the script to keep it)."
    echo
    echo "## Sizes"
    echo
    for f in "$OUT"/appstore/*.png "$OUT"/play/*.png; do
      echo "- ${f#$OUT/}: $(sips -g pixelWidth -g pixelHeight "$f" 2>/dev/null | awk '/pixel/{printf "%s ", $2}' | sed 's/ $//; s/ /x/')"
    done
  } > "$OUT/NOTES.md"
  echo "Wrote $OUT/NOTES.md"
fi

if (( FAILED )); then echo "Finished with failures (see $RAW/logs)." >&2; exit 1; fi
echo "Done: $OUT"
