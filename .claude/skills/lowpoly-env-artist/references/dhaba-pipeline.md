# Dhaba Rush pipeline (this repo)

Godot 4.7 (GL Compatibility, Android/iOS, portrait 720×1280) · Blender 5.2.2 LTS at
`/Applications/Blender.app/Contents/MacOS/Blender`. Every model is built procedurally by
`tools/blender/build_assets.py` plus the `v3_*.py` helper modules, from bmesh primitives into
`assets/models/<name>.glb`, with one shared palette material. There are no .blend files;
the Python IS the source art. Edit the builders, never the glb.

## Run

Rebuild everything (plus review renders when `--sheet` is given):

```bash
/Applications/Blender.app/Contents/MacOS/Blender -b --factory-startup -P tools/blender/build_assets.py -- assets/models --sheet docs/art/v3_sheet.png
```

- A `--sheet` name starting with `v3` writes the v0.3 renders next to it
  (`v3_world_preview.png`, `v3_sheet.png`, `v3_view_*.png`, `v3_characters.png`,
  `v3_vehicles.png`, `v3_munshi.png`, `v3_menu_sheet.png`, `v3_menu_dishes.png`).
- `DHABA_V3_RENDERS=world,views,menu,sheet,vehicles,munshi,chars` limits which renders run.
- `DHABA_PROFILE=1` prints triangles per exterior section.
- The build prints `[asset] name  tris  KB  nodes: ...  OVER BUDGET (n)` per asset and a
  `[budget] over:` summary. Fix anything over budget before reporting.
- Full rebuild takes a few minutes; run it in the background and read the log.
- Godot picks up the new glb on the next editor import / headless run; `scripts/world/models.gd`
  `Models.make("name")` loads `res://assets/models/name.glb` (hot-pink box fallback if missing).

## Axes and origins

Blender X = Godot X · Blender Z = Godot Y (up) · Blender −Y = Godot +Z (toward the camera).
`B(x, y, z)` converts Godot → Blender as `(x, −z, y)`. Characters and props face −Y
(Godot +Z); vehicles face +X. Origins sit on the ground at the footprint centre, except
WORLD-COORD assets (`ground`, `compound`, `scenery`, `wall_wire`, `wall_bulbs`, `dhaba_v3`,
`street_v3`) whose origin is the world origin and whose geometry is placed at world positions.
Station props: origin at the Layout3 anchor, customer side faces local +Z, staff stand ~0.9 m
behind (local z −0.9), customer spot +1.0..1.1; counter tops at y 0.72, pass ledge top y 0.80.

## Palette

`PALETTE` in `build_assets.py`: 96 hex swatches in an 8×12 grid of 16 px cells, named by
tuple-unpacked constants (`WOOD`, `STEEL`, `SAFFRON`, `MARIGOLD`, `SKIN_L`, `WALL_PINK`,
`NEEM`, ...). `swatch_uv(idx)` gives the cell centre UV; every primitive paints its faces
with it. One material (`make_material(img)`) with the palette image, Nearest-safe.

Adding a colour: append the hex at the END of `PALETTE` (keeps old UVs valid), extend the
last `range(...)` unpack with a new constant, keep `len(PALETTE) == COLS * ROWS` true
(bump `ROWS` by one when a row fills; the atlas grows downward). Comment the row with the
date and purpose like the existing rows. Prefer reusing a swatch: there are already
light/mid/dark triplets for wood, steel, plaster, dust, greens and skin.

## Primitive kit (`Asset` class, Blender space, metres)

All methods paint the swatch and return `self` so calls chain. `a = Asset("name")`.

| Call | What |
|---|---|
| `box(size, loc, color, rot=(0,0,0), nb=False)` | cube centred at loc; `nb` drops the hidden bottom face |
| `block(size, base, color, rot, nb=None)` | box standing on `base` (bottom centre); ground-standing ones auto-drop the bottom |
| `rbox(size, loc, color, rot, bevel=0.03, seg=1)` | bevelled box (the toy look); bevel clamps for thin slabs |
| `cyl(r, h, base, color, seg=8, rot, r2=None, nb=False)` | cylinder/cone standing on base |
| `tube(p0, p1, r0, color, r1=None, seg=8, caps=True)` | tapered cylinder between two points |
| `rod(p0, p1, r, color, seg=6)` / `beam(p0, p1, t, color, t2)` | round / square bar between points |
| `ball(r, centre, color, seg=8, rings=5, scale)` / `ell(centre, radii, color, frame, seg, rings)` | UV sphere / oriented ellipsoid |
| `ico(r, centre, color, subdiv=1, scale, rot)` | icosphere (beads, fruit, foliage) |
| `wheel(r, w, centre, color=TYRE, seg=10, axis="y")` | vehicle wheel |
| `face(pts, color, up=False, normal=None)` | arbitrary flat n-gon |
| `decal(c, w, h, facing, color, rot=0)` | flat quad facing `'+x' '-x' '+y' '-y' '+z'`, lift it ~1–2 mm |
| `place(fn, loc, rz, s, rot)` | run a builder fn and transform only what it added (reuse sub-builders) |
| `gblock / grect / gblob` | Godot-space helpers for WORLD-COORD assets |
| `tris()` | triangle count so far |
| `finish(mat, smooth=None)` | to mesh + object; `smooth=degrees` = smooth shading with sharp-angle split |

Helpers in `v3_common.py` / `build_assets.py`: `sag(p0, p1, s, n)` hanging-string points,
`bunting(...)`, `limb(a, pts, radii, color, ...)` tapered chain with ball joints, `disc(...)`
flat n-gon, `flower(...)` 10-tri bead, `text_geo(...)` baked Latin text (Baloo2 font; no
Devanagari shaping, use Label3D in Godot for Hindi), `frame(x_dir)` orthonormal basis,
`merge_objects(...)` single-mesh copy for renders.

## Multi-part models (moving parts)

```python
P = Parts("lassi_station", {"base": (0, 0, 0), "madhani": B(0.25, 1.02, -0.08)})  # pivots, Blender space
P["base"].rbox(...)            # build each part in MODEL space
P["madhani"].tube(...)
g = P.finish(mat, smooth=40)   # moves each part so its origin is the pivot, returns Group
g.extras.append(("steam_socket", B(-0.22, 1.05, -0.02)))   # empties exported next to the parts
```

`export_group(g, outdir)` writes the parts as top-level glb nodes named after the parts
(`body`, `head`, `arm_l`, ...) plus the socket empties. In Godot
`scripts/v3/world/character_rig.gd` finds `body/head/arm_l/arm_r/leg_l/leg_r` and swings
them; `station_node.gd` spins `madhani`, stirs `karchhi`, puffs steam from `steam_socket`.
Character pivots (Godot, unit height s≈0.94–1.08): body (0, 0.30s, 0), head (0, 0.64s, 0),
arm_l (+0.20s, 0.585s, 0), arm_r (−0.20s, ...), leg_l (+0.085s, 0.30s, 0), leg_r (−0.085s, ...).
Use `chibi(name, s, Look(...), extra=fn, hair="short|side|long")` in `v3_chars.py` for a
new walker; staff and busts have their own builders there. Posed busts are separate glbs
with the pose baked (`munshi_chai`, `munshi_cheer`, ...).

Fairy lights: `FairySet(name).string(key, poly, ...)` → `fairy_bulb_<key>` nodes with an
unlit material and COLOR_0 = bulb colour, alpha = animation code (<0.5 twinkle phase,
≥0.5 chase step), read by `assets/models/fairy_bulb.gdshader`.

## Budgets

`BUDGETS` / `budget_for()` (legacy): props 800, vehicles 2600, canopies 400, compound 3000,
scenery 6000, ground 800. `V3_BUDGETS` / `v3_budget()`: dhaba_v3 24 000, street_v3 38 000,
chai_counter_v3 4 000, tandoor_lock 3 500, characters 1 800, busts 3 000, others listed in
`build_assets.py` near line 1846. Add a line there for every new asset.

## Where things live

| Module | Builds |
|---|---|
| `build_assets.py` | palette, `Asset`, export, legacy v0.2 assets, `build_v3()` orchestration, `main()` |
| `v3_common.py` | `Parts`/`Group`/`export_group`, text, fairy lights, limb/disc helpers |
| `v3_props.py` | stations (chai counter, galla desk, tandoor, lassi, kadai), pass/tray/table dishes `pass_<dish>`, unlock props `prop_<name>`, banknote/sikka/marker/cash_brick, cow |
| `v3_chars.py` | travellers, staff, waiters, Munshi-ji busts (`chibi`, `Look`) |
| `v3_world.py` | dhaba interior / compound layout (world-coord `dhaba_v3`) |
| `v3_exterior.py` | highway, truck parking, trees, poles, fairy light strings (`street_v3`) |
| `v3_render.py` | review renders and contact sheets (game camera = Blender Euler (40°, 0, 45°)) |

Modules are loaded by path with `importlib`; `build_assets` injects its globals (palette
constants, `Asset`, `B`, `mat4`, `swatch_uv`, ...) into them, so new helper modules follow
the same pattern and don't import each other directly.

## Adding an asset, step by step

1. Brief (name, footprint, facing, pivot, budget, moving parts) and the design-doc
   position if there is one (`docs/v3-*.md`, `scripts/v3/world/layout3.gd`).
2. Write `build_<name>(mat)` in the module that owns its family, using the kit and existing
   palette constants. Multi-part → `Parts`; sockets → `g.extras`.
3. Register it in `build_v3()` (singles list or groups list) and add its budget.
4. Rebuild with `--sheet docs/art/v3_sheet.png` (or a narrower `DHABA_V3_RENDERS`), read the
   `[asset]` line, open the render, fix, repeat.
5. If code must find nodes, tell the user the node names and pivots; if the asset is placed
   by `layout3.gd`, give the Godot position and `rotation_degrees.y`.
6. Don't commit or export an APK unless asked (see the project memory).
