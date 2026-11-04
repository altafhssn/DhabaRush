# Test kit

The headless QA harness used for the core-and-feel build (3 Nov 2026) and the UI and feel redesign (`docs/ui-feel`). It ran from a session scratch folder; this is a copy so it is not lost. Godot ignores this folder (`.gdignore`).

**Copy it out of the project before use.** The scripts make test copies of the project ("slots", APFS clones) next to themselves, so running them inside the project would copy the project into itself.

```bash
cp -R tools/testkit ~/DhabaRushQA
```

Scripts that need the work folder read `DR_WORK` (default `~/DhabaRushQA`); the rest find their own folder. The project path defaults to `/Users/almeer/Documents/HighwayDhaba`.

| Folder | What it holds |
|---|---|
| `qa/` | The harness. `README.md` is the full guide. `mkslot.sh` makes a slot, `run.sh` runs the game headless in it (fixed 60 fps, at most 4 Godot processes at once, via `sem.sh`), `suite.sh` runs the tutorial suite, tap check and zoom test, and `tutcheck.py` compares tutorial beats with `logs/baseline` and `logs/baseline_wave4`. `savecheck.sh` must print SAVE OK before and after every batch: it checks that the real save is unchanged. `d4_probe.gd` and `d4_*.py` are the state probe and its analysis used by the redesign's measurements. `uxcap.sh` takes windowed screenshots, which needs the owner's approval each time. |
| `build/` | `tools/`: `gate.sh` (the QA gate), `gdtest.sh` (SceneTree tests in a slot), `wslot.sh`, `putsave.sh`, `snap.sh`, `blender.sh`, `glb_stats.py`. `fixtures/`: five 0.3.7 saves for load tests. |
| `d2work/` | The bot-based dead-stretch and buying analysis (`buylog.py`, `analyse.py`, `analyse2.py`) and its A/B run scripts. |

Rules that go with it: never run Godot on the real project or the real save; never export an APK or iOS build without the owner's approval of that build.
