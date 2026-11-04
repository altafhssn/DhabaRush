# Art audit (4 Nov 2026)

A read-only audit of everything the player sees and hears, done in five parallel passes on 4 Nov 2026 after the owner asked for "an audit of the design, the models and everything art". Nothing in the game was changed; Godot was not run; nothing was seen on a phone. The owner's page with the merged findings and the ranked change list is the "Dhaba Rush Art Audit" artifact; this folder holds the detailed write-ups and their evidence.

| Folder | Lens | Findings |
|---|---|---|
| `scene/` | The world as the player sees it: composition, colour, light, readability, cohesion. Marked-up pictures and mocks in `png/`. | S1-S17 |
| `characters/` | Every person and animal: proportions, variety, readability at phone size, animation, Munshi-ji's busts. Contact sheets and a mock in `png/`. | C1-C15 |
| `uifx/` | Icons, dish pictures, 3D models used in the UI, effects and celebrations, the app icon and splash, fonts, sound. Sheets in `png/`. | UA1-UA15 |
| `models/` | The technical health of all 145 `.glb` files: triangles against budgets, pivots, export hygiene, what is loaded, what ships. Inventory CSVs in `work/`. | M1-M11 |
| `pipeline/` | Whether the art can be rebuilt, grown and shipped safely: generators, the palette atlas, import settings, download size, what the pending plans need. | PA1-PA14 |

Each `findings.md` has the same shape: the answer first, measurements, numbered findings with severity (high / medium / low), evidence, the suggested change and its cost (S = a value or one file; M = some art or several files; L = a new art set), a ranked list, and what could not be checked.

**Evidence.** `work/` folders hold the scripts and their outputs (CSVs, measurement logs). The Blender renders, the fresh rebuild used for the pipeline comparison, the screenshot crops and the character tiles were not copied (they were session scratch files); the scripts regenerate them. Paths in the texts that start with `(session scratch)` pointed into that scratch folder.

**Checking.** Each pass's headline numbers were re-measured by the session itself (the palette copies, the missing imports, the six stale models, the missing cook models, the five traveller looks, the night light keys, the hire and table sounds, the NH 48 dish drawers), and a separate adversarial pass re-checked the fourteen biggest claims; its corrections, if any, are noted at the top of the affected `findings.md`.

**How it relates to the pending plans.** The audit does not choose a look (that is OD1 in `docs/ui-feel/proposal.md`); it says what the chosen look's icon and dish set must solve. Its floor, charpai and wall suggestions belong inside the playtest's renovation jobs (`docs/ui-feel/playtest-4nov/`), its dressing props inside the "a prop every 10 levels" item, and its pipeline items before any new art lands.
