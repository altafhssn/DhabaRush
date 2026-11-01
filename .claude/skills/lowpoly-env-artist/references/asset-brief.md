# Asset brief: template and defaults

Copy this block into the reply, fill it, and let the user correct it before building.
Every field maps to something that is expensive to change later (pivot, facing, scale)
or that the engine code depends on (node names, sockets).

```
ASSET      <snake_case_name>            file: <outdir>/<name>.glb
FAMILY     prop | station | building | vehicle | foliage | character | fx | world-coord
ROLE       gameplay (tapped / walked to) | set dressing | hero (camera lingers) | background
FOOTPRINT  x <w> m  ×  z <d> m,  height <h> m          (engine space, Y up)
ORIGIN     ground, footprint centre   | joint (moving part) | world origin (world-coord)
FACING     engine +Z (toward camera)  | engine +X (vehicles) | n/a
BUDGET     <n> triangles  (see defaults below)
SHADING    flat | smooth <angle>° (rounded organic parts only)
MOVING     none | nodes: <name>(pivot x,y,z) ...     sockets: <name>(x,y,z) ...
PALETTE    existing swatches only | + new: <HEX> <why>
REVIEW     game camera | front 3/4 | both
```

## Defaults by family

| Family | Budget (tris) | Origin | Facing | Shading | Notes |
|---|---|---|---|---|---|
| Small prop (cup, crate, sign) | 150–800 | ground, centre | +Z | flat | drop bottom face; ≥2 cm thickness |
| Station / counter (interactive) | 2 000–4 000 | ground, anchor point | +Z customer side | flat + smooth pots | staff spot ~0.9 m behind, customer spot ~1.0 m in front; pass ledge / slots as named flat discs |
| Building / kiosk | 3 000–8 000 | ground, footprint centre | door side +Z | flat | model only the visible sides; interior as separate asset if the camera sees in |
| Vehicle | 1 500–2 600 | ground, centre of wheelbase | +X (drives along +X) | flat | wheels as separate nodes if they spin; 10-seg wheels |
| Foliage (tree, bush, pot plant) | 100–600 | ground, trunk base | n/a | flat | canopy = 1–3 icospheres or ellipsoids, scaled, not many leaves |
| Character (chibi) | 1 200–1 800 | feet, between them | +Z | smooth 40° | parts: body, head, arm_l, arm_r, leg_l, leg_r |
| Bust / NPC portrait | ≤3 000 | waist | +Z | smooth 50° | parts: body, head, arm_l, arm_r |
| FX item (coin, note, marker) | ≤200 | centre (marker: tip) | +Z or face-up | flat | these spawn by the hundred; keep them tiny |
| World-coord set piece (ground, compound, scenery, wires) | 800–40 000 by scene | world origin | n/a | flat | geometry placed at world positions; split into sections so one edit doesn't rebuild everything |

Budgets assume a mobile game with a fixed isometric-ish camera at 9 to 12 m view size. For
a PC/console third-person game multiply by 3 to 5; for a hero prop the camera inspects,
by 2.

## Scale references (metres)

- Human: chibi 0.95–1.10 tall; realistic proportions 1.75.
- Counter / table top: 0.72–0.80. Chair seat: 0.45. Charpai (cot) top: 0.40.
- Door: 2.0 × 0.9. Window sill: 0.9. Single-storey roof edge: 2.8–3.2.
- Car: 4.2 × 1.8 × 1.5. Truck (two-axle): 7 × 2.4 × 3.2. Bus: 11 × 2.5 × 3.4.
- Small cup / glass: r 0.04, h 0.09. Plate: r 0.12. Pot (handi): r 0.18, h 0.22.

## Questions worth asking (only when the answer changes the build)

- Will any part be swapped or animated by code? (That decides the node split.)
- Is there a design-doc position for it? (Then the footprint and clearances are fixed.)
- Day/night: does it need an emissive variant (bulbs, windows)? (Vertex colour + unlit material.)
- Is it instanced many times? (Then budget tighter and avoid per-instance uniqueness.)
