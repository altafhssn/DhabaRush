# Stylized low-poly style guide

The target look is the "toy diorama" low poly seen in Idle Supermarket Tycoon, Townscaper,
Crossy Road and Alto's Odyssey: chunky forms, few deliberate facets, a warm saturated
palette, flat or lightly smoothed shading, and a camera far enough that detail is implied,
not modelled. Everything below serves readability at phone size.

## Proportion and form

- **Three reads.** Primary: the mass that identifies the object (one to three shapes).
  Secondary: what breaks the silhouette (awning, handle, roof overhang, wheels). Tertiary:
  surface accents (trim, decals, beads, bolts). Build in that order and stop when the next
  layer wouldn't be visible at the game camera distance.
- **Exaggerate the identifier.** Scale the defining feature up by 10–30 % and simplify
  everything else. A kettle is spout + lid; a truck is cab + grille + big wheels.
- **Squash and round.** Slightly squat proportions (0.9 height scale on buildings, big heads
  on characters) read friendlier and fit a portrait screen. Bevel big boxes (1–3 segments,
  2–5 % of the smallest dimension) so they feel moulded rather than cut.
- **Minimum feature size** at mobile scale: ~2 cm thickness, ~4 cm for anything that must be
  recognised. Below that, use a flat decal quad in a contrasting swatch instead of geometry.
- **Consistent segment counts** inside one asset: 6–8 for small round things, 10–14 for hero
  cylinders, 8×5 UV spheres for heads, icosphere subdiv 0–1 for beads and fruit.

## Colour and value

- **Value first.** Separate planes by brightness: top planes lightest, sides mid, undersides
  and recesses darkest. A good low-poly asset reads in greyscale.
- **Palette, not materials.** One material, one swatch atlas texture (grid of flat colour
  cells), per-face UVs placed at the cell centre. This gives one draw call per mesh, trivially
  recolourable assets, and no texture seams. Keep the atlas small (16 px cells, 8 columns) and
  nearest-neighbour filtered, or sample the cell centre so bilinear filtering can't bleed.
- **Swatch families.** Each material family gets a light / mid / dark triplet (wood, metal,
  plaster, foliage, skin, cloth). Accent colours (saffron, teal, red, pink) are shared across
  assets so the scene feels designed, not random.
- **Saturation by importance.** Interactive and hero objects get the saturated accents;
  background and ground get desaturated, slightly warm or cool versions of the same hues.
- **Warm light, cool shadow** is baked into the swatch choice: undersides lean cooler, lit
  tops lean warmer. The engine's directional light adds the rest.
- **Adding a swatch:** only when nothing existing reads right at game distance; append to the
  end of the list (so existing UV indices stay valid), name it, note the date and reason in
  the palette comment.

## Shading

- **Flat** for architecture, crates, vehicles, signs: it is the look.
- **Smooth with a sharp-angle split** (30–50°) for organic rounded parts: heads, bellies,
  pots, fruit, cushions. Bevelled box edges stay crisp, spheres go soft.
- Never leave default smooth on a faceted mesh (it produces the classic blotchy low-poly
  shading), and never flat-shade an 8-segment head (it reads as a gem).
- **Unlit / emissive** for bulbs, screens, fire cores: KHR_materials_unlit on export with a
  vertex colour, so the engine shows the colour without lighting. Glow is the engine's job.

## Detail that reads at distance

- Decals: flat quads lifted 1–2 mm off the surface in a contrasting swatch for stripes,
  signage blocks, tile grout lines, windows on far buildings.
- Text: baked Latin text as geometry only when it is big (signboards). Small text is a
  coloured bar. Non-Latin scripts: an engine Label3D over a blank board.
- Clutter in threes: three cups, three sacks, three bulbs, offset slightly, one rotated.
- Edge wear and dirt: a darker swatch band at the base of walls and a lighter one on top
  edges, nothing finer.
- Foliage: icosphere clusters (2–5) in two greens, trunk a 6-segment cone, no leaf cards on
  mobile.

## Characters (chibi)

- Height 1.0 m, head ≈ 35 % (radius 0.18–0.20), neck short, torso a rounded box, limbs
  tapered tubes with ball joints, hands as balls, feet as rounded blocks.
- Face: two dark eye beads or flat ovals, a small nose ball, optional moustache/brow quads.
  No mouth unless the pose needs it.
- Identity through costume colour blocks and one headwear or prop element (turban, cap,
  dupatta, tray). Keep skin, hair and eye swatches from the shared triplet set.
- Parts split for code animation: body (hips pivot), head (neck), arm_l / arm_r (shoulders),
  leg_l / leg_r (hips). Items carried are separate nodes or sockets.

## Scenes and dressing

- Model what the camera sees. Fixed isometric camera: skip the back faces of buildings,
  the undersides, the far side of the hill.
- World-coord set pieces (ground, compound walls, scenery) are placed at world positions and
  exported with origin at the world origin, so one file drops into the scene at (0,0,0).
  Split by section so a change to one area rebuilds only that section.
- Ground: a few large flat polygons in 2–3 dust/grass swatches plus irregular blobs for
  patches. No terrain mesh on mobile.
- Light strings, wires, ropes: 3-segment tubes with no caps; bulbs as 12-tri beads.

## Checks before calling it done

1. Black-silhouette test: hide materials, is it recognisable?
2. Greyscale test: do the planes separate?
3. Game-distance render: can you tell what each thing is at the actual on-screen size?
4. Counts: triangles vs budget, one material, no stray verts, normals outward.
5. Pivot, scale, facing match the brief.
