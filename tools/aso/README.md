# tools/aso

## Store screenshots and feature graphic (`make_store_art.sh`)

> **Google Play: superseded (2026-10-26).** The Play set (8 shots per language, feature graphic, icon) is now made by `docs/store/pipeline/make_store.sh` (docs/store/README.md). Running this script writes the old 7-shot set into `export/store/play/` and overwrites the new one.

Produces the creative set from `docs/aso.md` §6: seven captioned screenshots in English and Hindi at 1320×2868 (App Store 6.9") and 1080×1920 (Google Play), plus the 1024×500 Play feature graphic. Everything is captured from the running v0.3 build; no renders.

```bash
tools/aso/make_store_art.sh
```

About four minutes. Godot windows pop up during stage 1 (leave them alone). Output:

| Path | What |
|---|---|
| `export/store/appstore/shot1_en.png … shot7_hi.png` | 1320×2868, caption band on top |
| `export/store/play/shot1_en.png … shot7_hi.png` | 1080×1920 |
| `export/store/play/feature_graphic.png` | 1024×500, dusk, lorries, "Dhaba Rush / Highway Idle Tycoon" |
| `export/store/raw/<profile>/shotN/t0TT.T.png` | every raw frame (picked time + alternates) |
| `export/store/raw/<profile>/shotN.png` | the raw frame that was used |
| `export/store/NOTES.md` | placeholder list, deviations from §6, pixel sizes |
| `export/store/raw/logs/` | Godot output per capture and for the compositor |

Partial reruns:

```bash
tools/aso/make_store_art.sh --only=1,4        # recapture and recompose shots 1 and 4
tools/aso/make_store_art.sh --compose-only    # captions changed: reuse the raw frames
tools/aso/make_store_art.sh --feature-only    # just the feature graphic
```

### How it works

1. **Capture.** `shot_rig.tscn` (scene + `shot_rig.gd`, both in this folder) runs `scenes/main3.tscn` inside a SubViewport of the exact frame size, reproducing the project's `canvas_items`/`expand` stretch so the HUD lays out as on a phone of that aspect. A macOS window cannot be taller than the screen (1524 px here), so the rig is what makes 1320×2428 frames possible. The game's own debug flags (`--fresh --skip-tutorial --money --buy --open --seed --arrivals --speed --shots --shot-dir --quit-at`, see `scripts/v3/main3.gd`) drive the state; the rig adds capture-only flags: `--size=WxH`, `--cam=x,z[,zoom]`, `--light=night|dusk`, `--hud=off`, `--away=SEC` (offline popup). No gameplay script or scene is modified.
2. **Compose.** `compose/` is a tiny separate Godot project (so the game's autoloads never run while compositing). `compose.gd` draws the caption band with `assets/fonts/Baloo2.ttf` at weight 800 (Baloo 2 covers Devanagari; Noto Sans Devanagari is the fallback), puts the raw frame flush below, and writes the PNG at the exact size. This Mac's Python has no Pillow, which is why text is set in Godot.

The shot table (flags, picked time, alternates, EN/HI captions, notes) is at the top of `make_store_art.sh`; captions are copied from `docs/aso.md` §6. To change a camera, edit `--cam=x,z,zoom` there (`x,z` is the camera target in world metres from `Layout3`, zoom multiplies the gameplay ortho size: 1.0 = game, 1.3 = intro, 0.7 = focus). To change which frame is used for a shot, edit `SHOT_TIME[n]` (the file is `raw/<profile>/shotN/t0TT.T.png`), or just copy a different frame over `raw/<profile>/shotN.png` and run `--compose-only`.

Traffic is random; shots 1 and 4 (a lorry on the road, a bus at the stop) and the feature graphic (lorries in the lay-by) usually land at the listed times with `SEED=7`, but check them after a rerun and pick an alternate if a vehicle is missing.

The game save (`user://save3.json`) is backed up before stage 1 and restored when the script exits.

### Manual single frames

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path . res://tools/aso/shot_rig.tscn --resolution 405x720 -- \
  --fresh --skip-tutorial --money=3000 --seed=7 --size=1320x2428 --light=night --cam=3.4,8.6,1.3 \
  --shots=60,70,80 --quit-at=81 --shot-dir=/tmp/shots
```

## Competitor data (`store_scrape.py`)

`store_scrape.py` refreshes the competitor data behind `docs/aso.md`. It uses `curl` (macOS keychain certs) so run it with Blender's Python:

```bash
PY=/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13
$PY -I tools/aso/store_scrape.py itunes "dhaba@in" "idle tycoon@in" "truck stop@in"
$PY -I tools/aso/store_scrape.py lookup "1442064951@in"
$PY -I tools/aso/store_scrape.py play com.hybridparking.game com.DTGames.ChaiwalaTycoon
$PY -I tools/aso/store_scrape.py playsearch "dhaba game" "idle dhaba" "highway tycoon"
```

Modes: `itunes` (App Store search, `term@country`), `lookup` (App Store id), `play` (Play listing by package: title, short description, downloads, rating, reviews, ads/IAP, updated), `playsearch` (Play search results with package ids). Output is JSON on stdout.
