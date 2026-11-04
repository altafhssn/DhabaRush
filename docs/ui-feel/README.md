# UI and feel redesign

The owner's four complaints of 3 Nov 2026 (the UI does not fit the dhaba, "nothing to do", options hard to see, the dhaba is never full), diagnosed and designed. **Status: a design waiting for the owner's decisions. Nothing in the game has changed.** No build starts until the owner picks a look and approves the change list.

Start with `proposal.md`, then `change-list.md`.

| Folder | What is in it |
|---|---|
| `proposal.md` | The proposal for the owner: findings, gameplay tiers, the three looks, fixes for any look, decisions OD1-OD18, the build plan, what could not be checked |
| `change-list.md` | Every item (U, L-key, G, OD) with sources, cost, strings, tutorial impact and dependencies |
| `diagnosis/` | `summary.md` (root causes RC1-RC13, candidate fixes, constraints, owner questions) and the five checked reports D1-D5 |
| `gameplay/` | The two measured packages `ga.md` (pressure first) and `gb.md` (visibility first), each with its checker's Verification section; `synth.md`, the merged set G1-G25; `frames/` with F1-F6 (drawn in today's style) and their HTML |
| `looks/` | `truck/`, `khata/`, `tin/`: each a style guide (`style.md`, ending with the critic's "Critique and fixes"), ten mockups (`png/`) and their HTML and CSS (`html/`) |
| `compare/` | `compare.md`, the side-by-side sheets `cmp_01`-`cmp_10`, `cmp_split` and `cmp_split_07`, and the measurement outputs in `work/` |
| `evidence/` | The gameplay designers' scripts, prototype diffs (`proto_*.diff`) and pacing outputs: `ga/`, `gb/`, `syn/` (the run tables, follower and gap summaries) |

**Names used inside the documents.** DIAG = `diagnosis/summary.md`; SYN = `gameplay/synth.md`; FR = `gameplay/frames`; LK = `looks`; CMP = `compare`; WS = `evidence/syn`; WA = `evidence/ga`; BV or WB = `evidence/gb`.

**Not kept.** The work ran in a session scratch folder (paths starting `/private/tmp/claude-501/...`). The headless game logs, the QA test copies of the project (`qa/slots/...`), the clean world shots (`uxd/bg/...`) and the screenshots of today's game are not copied, so paths into them no longer resolve. The mockup HTML loads those world shots and fonts by absolute path, so it renders only on the machine that made it; the PNGs are the record.

**Method, in short.** Every gameplay number was measured in headless runs of a copy of the project (fixed 60 fps, seeds 1-4) or in `tools/sim/pacing_v3.py`, then re-run by a separate checker; a final check traced 50 numbers to their logs and re-ran two pacing marks. The real save was checked before and after every batch. The looks are browser mockups rendered at 720 x 1280, with every word as live text.
