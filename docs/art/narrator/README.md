# 2D narrator art

The dialogue narrator is 2D art from the owner's Gemini character sheet (4 Nov 2026), not the 3D Munshi-ji busts.
`scripts/v3/tutorial/munshi_bust.gd` uses the sprites in `assets/textures/narrator/` when they exist
(`SPRITE_PATH`), and falls back to the 3D `munshi_*.glb` busts when they do not.

| File | What it is |
|---|---|
| `narrator_sheet.webp` | The source sheet: 7 poses, 4 on top (idle, cheer, worried, point), 3 below (namaste, ledger, chai). |
| `cutout.py` | Cuts each pose out of the sheet with a transparent, defringed edge; writes `didi_<pose>.png` and `anchors.json` (head centre and hair top per pose). |
| `pack.py` | Mirrors each pose (so gestures reach towards screen centre), scales it to one head size and places it on a 748 x 517 canvas (the bust rect) with the head centre at x 425 and the hair top at y 58; writes `narrator_<pose>.png`. |

To swap in new art with the same layout:

```bash
Blender -b --factory-startup -P cutout.py -- narrator_sheet.webp cut
Blender -b --factory-startup -P pack.py -- cut sprites
```

Then copy `sprites/narrator_*.png` to `assets/textures/narrator/`. The chai pose is cut but not packed: the game does not use it.
A new sheet with a different layout or scale needs the row order in `cutout.py` and `SCALE` in `pack.py` checked.
