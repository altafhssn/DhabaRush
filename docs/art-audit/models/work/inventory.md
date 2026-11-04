# Dhaba Rush model inventory (145 .glb files, measured 2026-11-04)

Measured with `work/batch_check_glb.py` (Blender 5.2 headless import of each file, read-only; raw numbers in `glb_inventory.csv`, per-part lines in `glb_detail.txt`). Dimensions and pivot are in Godot space (X right, Y up, Z toward the camera), metres. `base_y` 0 = pivot at the base; `centre x,z` 0 = footprint centred on the pivot. Budget = `tools/blender/build_assets.py` `V3_BUDGETS` (line 1857), `V3_BUST_BUDGET` 3000 / `V3_CHAR_BUDGET` 1800 (line 1884), then the legacy `BUDGETS` / `budget_for()` (line 75-88; 800 when nothing names the model). Status: `dead (excluded from export)` = no script loads it and `export_presets.cfg` line 10 excludes it; `unused but shipped` = no script loads it, not excluded; `fallback only` = named only behind a model that exists; `loaded; no .import yet` = loaded by scripts but Godot has not imported it in this checkout.

## world (27 files, 77,749 triangles, 5,864 KB)

| file | status | KB | tris | verts | budget | % | meshes | mats | dims X×Y×Z m | base_y | centre x,z | empties | notes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---:|---|---:|---|
| street_v3 | loaded | 2485.9 | 32,691 | 69,181 | 38000 | 86 | 12 | 2 | 102.0×6.175×100.0 | -0.175 | 9.0, 10.0 | 0 | vertex colours (fairy bulbs) |
| dhaba_v3 | loaded | 1604.8 | 23,391 | 44,628 | 24000 | 97 | 8 | 2 | 23.1×5.47×14.044 | -0.25 | 4.0, 3.322 | 0 | vertex colours (fairy bulbs) |
| scenery | dead (excluded from export) | 425.8 | 5,908 | 12,418 | 6000 | 98 | 1 | 1 | 100.0×16.0×65.343 | -8.0 | 0.0, -15.283 | 0 |  |
| deco_baraat | loaded; no .import yet | 339.6 | 3,414 | 9,800 | 4000 | 85 | 2 | 2 | 6.261×3.065×0.255 | 0.5 | 4.5, 9.085 | 0 | vertex colours (fairy bulbs) |
| compound | dead (excluded from export) | 157.5 | 2,114 | 4,542 | 3000 | 70 | 1 | 1 | 21.0×3.15×20.58 | 0.0 | 0.0, -0.01 | 0 |  |
| family_hall | loaded; no .import yet | 158.3 | 1,909 | 4,357 | 6500 | 29 | 3 | 2 | 6.99×2.91×8.03 | 0.0 | 18.545, 4.125 | 0 | vertex colours (fairy bulbs) |
| tandoor_lock | loaded | 100.3 | 1,450 | 2,834 | 3500 | 41 | 1 | 1 | 3.287×1.485×7.838 | -0.015 | 7.2, 4.269 | 0 |  |
| hoarding | loaded; no .import yet | 91.8 | 948 | 2,246 | 1600 | 59 | 6 | 2 | 2.718×3.84×0.355 | 0.0 | 0.0, -0.053 | 3 | vertex colours (fairy bulbs) |
| chai_tapri | dead (excluded from export) | 56.5 | 786 | 1,558 | 800 | 98 | 1 | 1 | 2.82×3.265×2.41 | 0.0 | 0.0, 0.425 | 0 | no named budget |
| hut_1 | dead (excluded from export) | 55.9 | 743 | 1,547 | 800 | 93 | 1 | 1 | 8.9×3.96×3.137 | -0.02 | 0.0, 0.811 | 0 | no named budget |
| wall_bulbs | dead (excluded from export) | 60.6 | 576 | 1,728 | 700 | 82 | 1 | 1 | 19.407×1.616×14.378 | 0.63 | 0.097, 2.389 | 0 |  |
| signboard | dead (excluded from export) | 44.1 | 546 | 1,208 | 800 | 68 | 1 | 1 | 4.72×4.88×0.72 | 0.0 | 0.0, 0.14 | 0 | no named budget |
| ground | dead (excluded from export) | 37.7 | 442 | 1,022 | 800 | 55 | 1 | 1 | 100.0×0.522×100.0 | -0.04 | 0.0, -0.0 | 0 |  |
| wall_wire | dead (excluded from export) | 32.7 | 432 | 864 | 600 | 72 | 1 | 1 | 19.459×1.619×14.459 | 0.813 | 0.005, 2.495 | 0 |  |
| plant_pot | dead (excluded from export) | 31.1 | 332 | 832 | 800 | 42 | 1 | 1 | 0.609×0.842×0.58 | 0.0 | 0.003, -0.0 | 0 | no named budget |
| canopy_blue | dead (excluded from export) | 23.7 | 301 | 601 | 400 | 75 | 1 | 1 | 4.24×4.27×3.64 | 0.0 | 0.0, -0.0 | 0 |  |
| canopy_pink | dead (excluded from export) | 23.7 | 301 | 601 | 400 | 75 | 1 | 1 | 4.24×4.27×3.64 | 0.0 | 0.0, -0.0 | 0 |  |
| canopy_red | dead (excluded from export) | 23.7 | 301 | 601 | 400 | 75 | 1 | 1 | 4.24×4.27×3.64 | 0.0 | 0.0, -0.0 | 0 |  |
| canopy_teal | dead (excluded from export) | 23.7 | 301 | 601 | 400 | 75 | 1 | 1 | 4.24×4.27×3.64 | 0.0 | 0.0, -0.0 | 0 |  |
| canopy_yellow | dead (excluded from export) | 23.7 | 301 | 601 | 400 | 75 | 1 | 1 | 4.24×4.27×3.64 | 0.0 | 0.0, -0.0 | 0 |  |
| pump | dead (excluded from export) | 10.3 | 112 | 208 | 800 | 14 | 1 | 1 | 1.1×1.401×0.95 | 0.0 | 0.1, 0.075 | 0 | no named budget |
| lamp | dead (excluded from export) | 10.7 | 108 | 220 | 800 | 14 | 1 | 1 | 0.721×3.06×0.32 | 0.0 | 0.3, -0.0 | 0 | no named budget |
| string_bulbs | dead (excluded from export) | 13.5 | 104 | 312 | 800 | 13 | 1 | 1 | 3.8×0.457×0.2 | 2.5 | 0.0, 0.1 | 0 | no named budget |
| road | dead (excluded from export) | 8.0 | 72 | 144 | 400 | 18 | 1 | 1 | 100.0×0.042×4.0 | 0.0 | 0.0, -0.0 | 0 |  |
| string_wire | dead (excluded from export) | 8.1 | 72 | 144 | 800 | 9 | 1 | 1 | 4.208×0.379×0.03 | 2.685 | 0.0, 0.1 | 0 | no named budget |
| famous_board | dead (excluded from export) | 7.3 | 64 | 120 | 800 | 8 | 1 | 1 | 3.6×1.5×0.225 | -0.3 | 0.0, -0.038 | 0 | no named budget |
| parking_mark | dead (excluded from export) | 5.2 | 30 | 60 | 800 | 4 | 1 | 1 | 2.32×0.015×4.06 | 0.0 | 0.0, 0.03 | 0 | no named budget |

## stations+furniture (16 files, 15,697 triangles, 887 KB)

| file | status | KB | tris | verts | budget | % | meshes | mats | dims X×Y×Z m | base_y | centre x,z | empties | notes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---:|---|---:|---|
| chai_counter_v3 | loaded | 182.1 | 3,214 | 5,122 | 4000 | 80 | 1 | 1 | 2.52×1.705×0.905 | 0.0 | 0.0, 0.142 | 0 |  |
| kadai_station | loaded | 130.0 | 2,492 | 3,560 | 3200 | 78 | 2 | 1 | 1.32×1.331×0.905 | 0.0 | 0.0, 0.098 | 1 |  |
| lassi_station | loaded | 137.7 | 2,484 | 3,812 | 3000 | 83 | 2 | 1 | 1.645×1.54×2.128 | 0.0 | -0.352, -0.513 | 0 |  |
| tray_rack | loaded | 77.7 | 1,546 | 2,096 | 1800 | 86 | 1 | 1 | 0.676×1.098×0.402 | 0.0 | 0.008, 0.011 | 0 |  |
| tandoor_station | loaded | 65.9 | 1,404 | 1,744 | 3000 | 47 | 1 | 1 | 1.98×1.254×1.091 | -0.002 | 0.0, 0.005 | 0 |  |
| galla_desk | loaded | 56.5 | 1,184 | 1,484 | 3000 | 39 | 1 | 1 | 1.33×1.005×0.733 | 0.0 | 0.0, 0.026 | 0 |  |
| family_table | loaded; no .import yet | 38.7 | 702 | 1,004 | 900 | 78 | 1 | 1 | 1.741×0.745×2.761 | 0.0 | 0.0, 0.001 | 0 |  |
| dining_table | loaded | 25.7 | 430 | 640 | 1000 | 43 | 1 | 1 | 1.7×0.666×0.8 | 0.0 | 0.0, -0.0 | 0 |  |
| cashier_desk | dead (excluded from export) | 29.9 | 409 | 777 | 800 | 51 | 1 | 1 | 2.555×2.78×1.402 | 0.0 | 0.197, -0.259 | 0 | no named budget |
| charpai | loaded | 25.1 | 358 | 636 | 1200 | 30 | 1 | 1 | 1.6×0.45×0.864 | 0.0 | 0.0, -0.0 | 0 |  |
| station_chai | dead (excluded from export) | 24.8 | 336 | 628 | 800 | 42 | 1 | 1 | 1.64×1.46×0.84 | 0.0 | 0.0, -0.0 | 0 | no named budget |
| station_tandoor | dead (excluded from export) | 21.4 | 298 | 526 | 800 | 37 | 1 | 1 | 1.671×1.433×1.012 | 0.0 | -0.046, -0.05 | 0 | no named budget |
| tv_set | loaded; no .import yet | 27.0 | 294 | 674 | 300 | 98 | 2 | 1 | 0.74×0.771×0.423 | -0.34 | 0.0, 0.07 | 0 |  |
| plate_stool | loaded; no .import yet | 14.8 | 248 | 324 | 300 | 83 | 1 | 1 | 0.576×0.664×0.576 | 0.0 | 0.0, -0.0 | 0 |  |
| seats_board | loaded; no .import yet | 21.3 | 222 | 508 | 300 | 74 | 2 | 1 | 1.08×0.721×0.373 | 0.0 | 0.0, -0.116 | 1 | 1 rotated node |
| cash_table | dead (excluded from export) | 8.3 | 76 | 152 | 800 | 10 | 1 | 1 | 1.0×0.86×0.6 | 0.0 | 0.0, -0.0 | 0 | no named budget |

## props (14 files, 2,794 triangles, 177 KB)

| file | status | KB | tris | verts | budget | % | meshes | mats | dims X×Y×Z m | base_y | centre x,z | empties | notes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---:|---|---:|---|
| prop_dal_handi | loaded | 13.2 | 242 | 276 | 250 | 97 | 1 | 1 | 0.182×0.145×0.152 | 0.0 | 0.015, -0.0 | 0 |  |
| prop_green_tea_jar | loaded | 14.8 | 242 | 326 | 250 | 97 | 1 | 1 | 0.149×0.17×0.11 | 0.0 | -0.0, -0.003 | 0 |  |
| prop_keema_pot | loaded | 14.1 | 232 | 306 | 250 | 93 | 1 | 1 | 0.271×0.406×0.26 | 0.0 | 0.005, 0.0 | 0 |  |
| prop_naan_basket | loaded | 13.8 | 220 | 300 | 250 | 88 | 1 | 1 | 0.3×0.515×0.3 | 0.0 | 0.0, -0.0 | 0 |  |
| tray_wide | loaded; no .import yet | 12.5 | 220 | 256 | 300 | 73 | 1 | 1 | 0.694×0.036×0.396 | 0.0 | 0.0, -0.0 | 0 |  |
| prop_coffee_kettle | loaded | 13.2 | 216 | 280 | 250 | 86 | 1 | 1 | 0.177×0.235×0.104 | 0.0 | 0.001, -0.0 | 0 |  |
| prop_milk_can | loaded | 12.7 | 216 | 264 | 250 | 86 | 1 | 1 | 0.166×0.294×0.144 | 0.0 | 0.011, -0.0 | 0 |  |
| prop_kulcha_board | loaded | 13.6 | 204 | 294 | 250 | 82 | 1 | 1 | 0.28×0.397×0.28 | 0.0 | 0.0, -0.0 | 0 |  |
| tray | loaded | 10.5 | 192 | 200 | 300 | 64 | 1 | 1 | 0.416×0.036×0.416 | 0.0 | 0.0, -0.0 | 0 |  |
| prop_chaas_jug | loaded | 12.6 | 176 | 268 | 250 | 70 | 1 | 1 | 0.128×0.175×0.087 | 0.0 | -0.0, -0.0 | 0 |  |
| prop_mango_crate | loaded | 13.0 | 174 | 280 | 250 | 70 | 1 | 1 | 0.16×0.108×0.11 | 0.0 | 0.0, 0.0 | 0 |  |
| prop_chole_sack | loaded | 13.1 | 172 | 286 | 250 | 69 | 1 | 1 | 0.268×0.328×0.23 | -0.002 | 0.0, -0.0 | 0 |  |
| prop_patiala_glass | loaded | 9.5 | 152 | 174 | 250 | 61 | 1 | 1 | 0.124×0.258×0.13 | 0.0 | -0.0, 0.0 | 0 |  |
| prop_paneer_block | loaded | 10.0 | 136 | 192 | 250 | 54 | 1 | 1 | 0.14×0.058×0.14 | 0.0 | -0.0, -0.0 | 0 |  |

## dishes (26 files, 8,110 triangles, 465 KB)

| file | status | KB | tris | verts | budget | % | meshes | mats | dims X×Y×Z m | base_y | centre x,z | empties | notes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---:|---|---:|---|
| pass_bhurji | loaded | 32.0 | 580 | 812 | 600 | 97 | 1 | 1 | 0.27×0.08×0.27 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_baati | loaded; no .import yet | 24.0 | 492 | 574 | 550 | 89 | 1 | 1 | 0.27×0.079×0.27 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_dal_baati | loaded; no .import yet | 27.7 | 490 | 692 | 550 | 89 | 1 | 1 | 0.272×0.071×0.272 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_missi_roti | loaded; no .import yet | 23.5 | 420 | 570 | 550 | 76 | 1 | 1 | 0.27×0.07×0.27 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_lahsun_roti | loaded; no .import yet | 20.5 | 408 | 476 | 550 | 74 | 1 | 1 | 0.27×0.045×0.27 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_keema_paratha | loaded | 25.3 | 396 | 632 | 600 | 66 | 1 | 1 | 0.27×0.043×0.27 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_chole | loaded | 20.6 | 356 | 490 | 500 | 71 | 1 | 1 | 0.201×0.072×0.2 | 0.0 | -0.003, -0.0 | 0 |  |
| pass_ker_sangri | loaded; no .import yet | 19.2 | 348 | 446 | 550 | 63 | 1 | 1 | 0.195×0.095×0.2 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_laal_maas | loaded; no .import yet | 21.1 | 346 | 510 | 550 | 63 | 1 | 1 | 0.195×0.089×0.2 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_gatte | loaded; no .import yet | 20.8 | 340 | 500 | 550 | 62 | 1 | 1 | 0.195×0.075×0.2 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_paneer | loaded | 24.0 | 338 | 602 | 500 | 68 | 1 | 1 | 0.201×0.072×0.2 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_rabri | loaded; no .import yet | 18.5 | 338 | 428 | 550 | 61 | 1 | 1 | 0.154×0.085×0.158 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_kulcha | loaded | 17.4 | 334 | 392 | 600 | 56 | 1 | 1 | 0.27×0.066×0.27 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_shikanji | loaded; no .import yet | 17.4 | 318 | 396 | 550 | 58 | 1 | 1 | 0.14×0.185×0.144 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_mango_lassi | loaded | 16.0 | 294 | 354 | 400 | 74 | 1 | 1 | 0.146×0.194×0.15 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_roti | loaded | 14.8 | 284 | 318 | 600 | 47 | 1 | 1 | 0.27×0.055×0.27 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_kesar_doodh | loaded | 15.5 | 240 | 348 | 400 | 60 | 1 | 1 | 0.184×0.132×0.184 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_naan | loaded | 14.6 | 236 | 322 | 600 | 39 | 1 | 1 | 0.27×0.05×0.27 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_patiala | loaded | 13.1 | 230 | 274 | 400 | 58 | 1 | 1 | 0.175×0.279×0.18 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_lassi | loaded | 12.9 | 220 | 270 | 400 | 55 | 1 | 1 | 0.146×0.199×0.15 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_green_tea | loaded | 13.4 | 216 | 288 | 400 | 54 | 1 | 1 | 0.15×0.096×0.15 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_dal | loaded | 12.2 | 214 | 248 | 500 | 43 | 1 | 1 | 0.195×0.077×0.2 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_kulhad | loaded; no .import yet | 10.0 | 180 | 186 | 450 | 40 | 1 | 1 | 0.192×0.132×0.184 | 0.0 | 0.004, -0.0 | 0 |  |
| pass_chaas | loaded | 11.2 | 176 | 224 | 400 | 44 | 1 | 1 | 0.146×0.163×0.15 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_plate | loaded | 10.0 | 174 | 186 | 450 | 39 | 1 | 1 | 0.122×0.125×0.122 | 0.0 | 0.0, -0.0 | 0 |  |
| pass_coffee | loaded | 8.9 | 142 | 156 | 400 | 36 | 1 | 1 | 0.148×0.118×0.148 | 0.0 | 0.0, -0.0 | 0 |  |

## characters (35 files, 49,192 triangles, 2,365 KB)

| file | status | KB | tris | verts | budget | % | meshes | mats | dims X×Y×Z m | base_y | centre x,z | empties | notes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---:|---|---:|---|
| cow | loaded | 79.5 | 1,820 | 2,048 | 2000 | 91 | 3 | 1 | 1.595×0.912×0.732 | 0.0 | 0.076, -0.0 | 0 |  |
| bhurji_wala | loaded | 81.8 | 1,796 | 2,064 | 1800 | 100 | 6 | 1 | 0.598×1.04×0.505 | 0.0 | 0.0, 0.022 | 0 |  |
| gopal | loaded; no .import yet | 79.6 | 1,796 | 1,990 | 1800 | 100 | 6 | 1 | 0.604×1.05×0.433 | 0.0 | 0.0, -0.013 | 1 |  |
| neetu | loaded | 87.1 | 1,784 | 2,236 | 1800 | 99 | 6 | 1 | 0.568×0.988×0.425 | 0.0 | 0.0, -0.02 | 0 |  |
| trav_elder | loaded; no .import yet | 87.8 | 1,784 | 2,230 | 1800 | 99 | 7 | 1 | 0.586×0.991×0.415 | -0.001 | 0.0, -0.01 | 0 |  |
| balwant | loaded; no .import yet | 80.9 | 1,782 | 2,038 | 1800 | 99 | 6 | 1 | 0.647×1.171×0.469 | 0.0 | -0.006, -0.012 | 0 |  |
| dal_wala | loaded | 85.9 | 1,776 | 2,198 | 1800 | 99 | 6 | 1 | 0.58×1.009×0.475 | 0.0 | 0.0, -0.015 | 0 |  |
| pinky | loaded | 85.4 | 1,776 | 2,182 | 1800 | 99 | 6 | 1 | 0.574×0.998×0.425 | 0.0 | 0.0, -0.019 | 0 |  |
| trav_techie | loaded; no .import yet | 83.0 | 1,776 | 2,106 | 1800 | 99 | 6 | 1 | 0.58×1.009×0.472 | 0.0 | 0.0, -0.04 | 0 |  |
| kallu | loaded | 85.1 | 1,748 | 2,178 | 1800 | 97 | 6 | 1 | 0.628×1.03×0.432 | 0.0 | -0.009, -0.01 | 0 |  |
| raju | loaded | 79.4 | 1,748 | 1,994 | 1800 | 97 | 6 | 1 | 0.61×1.061×0.438 | 0.0 | 0.0, -0.013 | 1 |  |
| trav_baraati_f | loaded; no .import yet | 83.6 | 1,744 | 2,128 | 1800 | 97 | 6 | 1 | 0.574×0.998×0.475 | 0.0 | 0.0, -0.007 | 0 |  |
| lassi_wala | loaded | 85.2 | 1,734 | 2,184 | 1800 | 96 | 6 | 1 | 0.61×1.107×0.442 | 0.0 | 0.0, -0.011 | 0 |  |
| pappu | loaded | 78.1 | 1,728 | 1,958 | 1800 | 96 | 6 | 1 | 0.598×1.055×0.429 | 0.0 | 0.0, -0.013 | 1 |  |
| sonu | loaded | 77.5 | 1,728 | 1,936 | 1800 | 96 | 6 | 1 | 0.598×1.092×0.46 | 0.0 | 0.0, -0.028 | 1 |  |
| trav_farmer | loaded; no .import yet | 78.1 | 1,724 | 1,958 | 1800 | 96 | 6 | 1 | 0.598×1.12×0.456 | 0.0 | 0.0, -0.013 | 0 |  |
| trav_trucker | loaded | 73.9 | 1,704 | 1,828 | 1800 | 95 | 6 | 1 | 0.646×1.188×0.486 | 0.0 | 0.0, -0.005 | 0 |  |
| trav_family_f | loaded | 77.6 | 1,664 | 1,952 | 1800 | 92 | 6 | 1 | 0.574×0.998×0.456 | 0.0 | 0.0, -0.017 | 0 |  |
| trav_sardar | loaded; no .import yet | 73.8 | 1,612 | 1,842 | 1800 | 90 | 6 | 1 | 0.646×1.193×0.477 | 0.0 | 0.0, -0.012 | 0 |  |
| bablu | loaded | 74.6 | 1,548 | 1,880 | 1800 | 86 | 6 | 1 | 0.586×1.049×0.42 | 0.0 | 0.0, -0.012 | 0 |  |
| trav_baraati_m | loaded; no .import yet | 72.1 | 1,540 | 1,800 | 1800 | 86 | 6 | 1 | 0.622×1.165×0.468 | 0.0 | 0.0, -0.01 | 0 |  |
| bittu | loaded | 69.9 | 1,504 | 1,740 | 1800 | 84 | 6 | 1 | 0.598×1.08×0.429 | 0.0 | 0.0, -0.013 | 0 |  |
| lakhan | loaded; no .import yet | 68.3 | 1,472 | 1,690 | 1800 | 82 | 6 | 1 | 0.61×1.061×0.438 | 0.0 | 0.0, -0.013 | 1 |  |
| trav_biker | loaded | 66.0 | 1,472 | 1,618 | 1800 | 82 | 6 | 1 | 0.61×1.093×0.481 | 0.0 | 0.0, -0.035 | 0 |  |
| trav_family_m | loaded | 64.2 | 1,416 | 1,570 | 1800 | 79 | 6 | 1 | 0.598×1.04×0.429 | 0.0 | 0.0, -0.013 | 0 |  |
| munna | loaded | 65.2 | 1,388 | 1,610 | 1800 | 77 | 6 | 1 | 0.598×1.04×0.429 | 0.0 | 0.0, -0.013 | 0 |  |
| trav_student | loaded | 66.4 | 1,380 | 1,648 | 1800 | 77 | 6 | 1 | 0.562×0.997×0.439 | 0.0 | 0.0, -0.03 | 0 |  |
| dog_sit | loaded; no .import yet | 43.3 | 1,008 | 1,040 | 1200 | 84 | 3 | 1 | 0.425×0.598×0.568 | -0.002 | 0.045, -0.012 | 0 |  |
| dog | loaded | 29.9 | 768 | 712 | 1200 | 64 | 1 | 1 | 0.74×0.27×0.56 | 0.0 | 0.015, 0.06 | 0 |  |
| customer_c | fallback only (shipped, never loaded) | 40.5 | 500 | 1,100 | 1800 | 28 | 1 | 1 | 0.631×1.21×0.487 | 0.0 | 0.0, -0.019 | 0 |  |
| bhaiya | dead (excluded from export) | 36.6 | 452 | 984 | 1800 | 25 | 1 | 1 | 0.691×1.176×0.525 | 0.0 | 0.0, -0.008 | 0 |  |
| customer_b | fallback only (shipped, never loaded) | 34.6 | 428 | 924 | 1800 | 24 | 1 | 1 | 0.601×1.023×0.48 | 0.0 | 0.0, -0.03 | 0 |  |
| customer_d | fallback only (shipped, never loaded) | 30.9 | 376 | 816 | 1800 | 21 | 1 | 1 | 0.571×1.035×0.508 | 0.0 | 0.0, 0.031 | 0 |  |
| chotu | dead (excluded from export) | 30.0 | 364 | 792 | 1800 | 20 | 1 | 1 | 0.481×0.818×0.348 | 0.0 | 0.0, -0.014 | 0 |  |
| customer_a | fallback only (shipped, never loaded) | 29.2 | 352 | 768 | 1800 | 20 | 1 | 1 | 0.601×1.023×0.435 | 0.0 | 0.0, -0.017 | 0 |  |

## vehicles (11 files, 9,790 triangles, 657 KB)

| file | status | KB | tris | verts | budget | % | meshes | mats | dims X×Y×Z m | base_y | centre x,z | empties | notes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---:|---|---:|---|
| bus_baraat | loaded; no .import yet | 156.1 | 1,955 | 4,526 | 2000 | 98 | 1 | 1 | 6.895×2.585×2.625 | 0.0 | 0.078, -0.003 | 0 |  |
| truck | loaded | 106.0 | 1,773 | 2,957 | 2600 | 68 | 1 | 1 | 4.723×2.654×2.34 | 0.0 | -0.037, -0.0 | 0 |  |
| truck_green | loaded | 106.0 | 1,773 | 2,957 | 2600 | 68 | 1 | 1 | 4.723×2.654×2.34 | 0.0 | -0.037, -0.0 | 0 |  |
| camel_cart | loaded; no .import yet | 99.4 | 1,626 | 2,776 | 1800 | 90 | 1 | 1 | 4.198×1.61×1.5 | 0.0 | 1.219, -0.0 | 0 |  |
| bus | loaded | 69.5 | 1,075 | 1,922 | 2600 | 41 | 1 | 1 | 6.895×2.74×2.625 | 0.0 | 0.078, -0.003 | 0 |  |
| car | loaded | 21.6 | 292 | 536 | 2600 | 11 | 1 | 1 | 2.452×1.19×1.28 | 0.0 | 0.005, -0.0 | 0 |  |
| car_blue | loaded | 21.6 | 292 | 536 | 2600 | 11 | 1 | 1 | 2.452×1.19×1.28 | 0.0 | 0.005, -0.0 | 0 |  |
| car_red | loaded | 21.6 | 292 | 536 | 2600 | 11 | 1 | 1 | 2.452×1.19×1.28 | 0.0 | 0.005, -0.0 | 0 |  |
| car_taxi | loaded | 21.6 | 292 | 536 | 2600 | 11 | 1 | 1 | 2.452×1.19×1.28 | 0.0 | 0.005, -0.0 | 0 |  |
| auto | loaded | 18.8 | 240 | 456 | 2600 | 9 | 1 | 1 | 1.762×1.36×1.15 | 0.0 | 0.031, -0.015 | 0 |  |
| bike | loaded | 15.1 | 180 | 348 | 2600 | 7 | 1 | 1 | 1.564×0.89×0.62 | 0.0 | 0.025, -0.0 | 0 |  |

## ui/fx (16 files, 23,514 triangles, 865 KB)

| file | status | KB | tris | verts | budget | % | meshes | mats | dims X×Y×Z m | base_y | centre x,z | empties | notes |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---:|---|---:|---|
| munshi_point | loaded | 97.4 | 2,988 | 2,374 | 3000 | 100 | 4 | 1 | 1.738×1.554×1.024 | -0.2 | -0.204, 0.147 | 0 |  |
| munshi_cheer | loaded | 94.8 | 2,930 | 2,302 | 3000 | 98 | 4 | 1 | 1.692×1.553×0.803 | -0.2 | 0.096, -0.011 | 0 |  |
| munshi_chai | unused but shipped | 98.6 | 2,922 | 2,424 | 3000 | 97 | 4 | 1 | 1.291×1.553×0.914 | -0.2 | 0.02, 0.057 | 0 |  |
| munshi_idle | loaded | 95.1 | 2,922 | 2,312 | 3000 | 97 | 4 | 1 | 1.251×1.55×0.786 | -0.2 | 0.04, 0.028 | 0 |  |
| munshi_ledger | loaded | 90.5 | 2,888 | 2,170 | 3000 | 96 | 4 | 1 | 1.271×1.56×1.045 | -0.2 | 0.01, 0.158 | 0 |  |
| munshi_namaste | loaded | 92.7 | 2,752 | 2,266 | 3000 | 92 | 4 | 1 | 1.093×1.56×0.961 | -0.2 | 0.0, 0.116 | 0 |  |
| munshi_worried | loaded | 84.8 | 2,728 | 2,018 | 3000 | 91 | 4 | 1 | 1.171×1.554×0.756 | -0.2 | 0.0, 0.013 | 0 |  |
| cash_brick | dead (excluded from export) | 53.5 | 1,240 | 1,376 | 2000 | 62 | 1 | 1 | 0.86×0.278×0.545 | -0.004 | 0.0, 0.03 | 0 |  |
| banknote | loaded | 26.5 | 454 | 662 | 700 | 65 | 1 | 1 | 0.8×0.054×0.51 | -0.027 | 0.0, -0.0 | 0 |  |
| banknote_saffron | dead (excluded from export) | 26.6 | 454 | 662 | 700 | 65 | 1 | 1 | 0.8×0.054×0.51 | -0.027 | 0.0, -0.0 | 0 |  |
| marker | loaded | 46.9 | 452 | 1,316 | 900 | 50 | 1 | 1 | 1.149×1.004×1.145 | 0.0 | 0.0, -0.0 | 0 |  |
| padlock | dead (excluded from export) | 21.8 | 304 | 540 | 800 | 38 | 1 | 1 | 0.4×0.552×0.205 | 0.0 | 0.0, 0.002 | 0 | no named budget |
| sikka | unused but shipped | 14.7 | 280 | 316 | 900 | 31 | 1 | 1 | 0.5×0.5×0.084 | -0.25 | 0.0, -0.0 | 0 |  |
| icon_roti | dead (excluded from export) | 10.2 | 120 | 204 | 800 | 15 | 1 | 1 | 0.323×0.095×0.34 | 0.0 | 0.0, -0.0 | 0 | no named budget |
| icon_chai | dead (excluded from export) | 6.5 | 56 | 96 | 800 | 7 | 1 | 1 | 0.22×0.22×0.22 | 0.0 | 0.0, -0.0 | 0 | no named budget |
| cash | unused but shipped | 4.8 | 24 | 48 | 800 | 3 | 1 | 1 | 0.23×0.095×0.42 | 0.0 | 0.0, -0.0 | 0 | no named budget |

## Hygiene columns (same for all 145 files unless noted)

- generator: Khronos glTF Blender I/O v5.2.40 (all 145)
- embedded image: one `palette` PNG 128×192 in every file (1,740 bytes each)
- texture sampler: NEAREST (9728) in every file
- cameras / lights / animations / skins: 0 in every file
- unapplied object rotation or scale: 0 in every file (one rotated node: seats_board's text socket)
- `.001`-style duplicate names: 0; Godot `-col`/`-noimp` hint suffixes: 0
- UV + normals present in every file; vertex colours only in the 5 files with fairy_bulb strings
