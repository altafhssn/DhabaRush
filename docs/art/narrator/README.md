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

# 3D Rani (10 Nov 2026)

The narrator in the game is now a 3D bust built in code toward the same sheet: `tools/blender/v3_rani.py`
(`build_rani3`). When `assets/models/rani_idle.glb` exists, `munshi_bust.gd` uses the six `rani_<pose>.glb`
busts and ignores the 2D sprites above. The sprites stay in the project as the fallback.

| File | What it is |
|---|---|
| `tools/blender/v3_rani.py` | The builder: sculpted head, eyes, hair, hands, clothes, her own texture and baked shading. About 23,700 triangles per pose. |
| `rani_build.py` (this folder) | Builds only Rani, without the full asset build: exports the six glbs, renders review pictures, a wireframe view and the face icon, and measures the eye spacing. |
| `assets/models/rani_<pose>.glb` | The six busts (nodes `body`, `head`, `arm_l`, `arm_r`). Godot extracts `rani_<pose>_rani_tex.png` from each. |
| `assets/textures/narrator/rani_face.png` | The round face icon (STAFF, the reaction chip), rendered from the idle bust. |

To rebuild her after a change to `v3_rani.py` (run from a scratch folder, not from the project):

```bash
Blender -b --factory-startup -P <project>/docs/art/narrator/rani_build.py -- out/glb --render=out/render --hands --wire --face=out/rani_face.png --measure
```

Then copy `out/glb/rani_*.glb` to `assets/models/` and `out/rani_face.png` to `assets/textures/narrator/`.
The glb files are not byte-identical from one run to the next (the exporter orders some data differently), so
only copy them when the model changed.

Decisions the owner made on 10 Nov, which the numbers in `v3_rani.py` encode:

- Proportions follow the sheet, not the chibi travellers: a smaller head, almond eyes, a visible but short neck.
- Eyes sit a little closer than the sheet's: the gap is about 0.96 of an eye-width (`R3_EX`, `R3_GAZE_X`).
- Hands are about 0.41 of the head's height (`R3_HAND`).
- In the game the bust is drawn 18% larger (`MunshiBust.MODEL_SCALE`) so her face stays readable on a phone.

