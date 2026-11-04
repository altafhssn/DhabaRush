"""Parse the PROG in-game logs: steady window 120-600 s of game time after the scene (the setup buys at 0.5 s and
the ramp eases up in the first minute). Per log: road cap, mean ramp target, the floor stage capacities (mean),
arrivals/min, takings/min (cash delta: nothing is bought after the setup), seats in use (mean, share of samples
with every seat taken, share with a door line), riders sent past, mean food wait, conservation.
Usage: python3.13 -I -B parse.py LOGDIR"""
import re
import sys
from pathlib import Path

T0, T1 = 120.0, 600.0
rows = []
for p in sorted(Path(sys.argv[1]).glob("*.log")):
    if p.name.startswith("test_"):
        continue
    txt = p.read_text(errors="replace").splitlines()
    samples = []
    cur = None
    for ln in txt:
        m = re.match(r"\[stats\] ([0-9.]+) cash ([0-9.]+) sales (\d+) .*? seats (\d+)/(\d+) door (\d+) .*?\| passed (\d+) .*?\| cap ([0-9.]+)", ln)
        if m:
            cur = dict(t=float(m.group(1)), cash=float(m.group(2)), sales=int(m.group(3)), u=int(m.group(4)), n=int(m.group(5)),
                       door=int(m.group(6)), passed=int(m.group(7)), cap=float(m.group(8)))
            samples.append(cur)
            continue
        if cur is None:
            continue
        m = re.search(r"ramp ([0-9.]+)/min .*?capacity seats ([0-9.]+) waiters ([0-9.]+) stations ([0-9.]+) gallas ([0-9.]+)", ln)
        if m and ln.startswith("[stats]    ramp"):
            cur.update(ramp=float(m.group(1)), cs=float(m.group(2)), cw=float(m.group(3)), cst=float(m.group(4)), cg=float(m.group(5)))
        m = re.match(r"\[stats\]    arrivals (\d+)", ln)
        if m:
            cur["arr"] = int(m.group(1))
    win = [s for s in samples if T0 - 0.5 <= s["t"] <= T1 + 0.5]
    if len(win) < 2:
        rows.append((p.stem, None))
        continue
    a, b = win[0], win[-1]
    mins = (b["t"] - a["t"]) / 60.0
    mean = lambda k: sum(s.get(k, 0.0) for s in win) / len(win)
    full = sum(1 for s in win if s["u"] >= s["n"]) / len(win)
    door = sum(1 for s in win if s["door"] > 0) / len(win)
    fw = re.search(r"avg food wait ([0-9.]+) s", "\n".join(l for l in txt if l.startswith("[summary] sim")))
    gl = re.search(r"avg galla line ([0-9.]+)", "\n".join(l for l in txt if l.startswith("[summary] sim")))
    cons = next((l for l in txt if l.startswith("[sim] conservation")), "")
    lu = re.search(r"left_unpaid (\d+)", cons)
    rows.append((p.stem, dict(cap=b["cap"], ramp=mean("ramp"), cs=mean("cs"), cw=mean("cw"), cst=mean("cst"), cg=mean("cg"),
                              arr=(b.get("arr", 0) - a.get("arr", 0)) / mins, take=(b["cash"] - a["cash"]) / mins,
                              seats=mean("u"), n=b["n"], full=full, door=door, passed=b["passed"] - a["passed"],
                              fw=float(fw.group(1)) if fw else -1, gl=float(gl.group(1)) if gl else -1,
                              lu=int(lu.group(1)) if lu else -1)))
print(f"{'run':<10} {'cap':>5} {'ramp':>5} | {'seatsC':>6} {'waitC':>6} {'cookC':>6} {'cashC':>6} | {'arr/m':>6} {'take/m':>8} | seats used      full  door | passed foodw galla_line unpaid")
for name, r in rows:
    if r is None:
        print(f"{name:<10} (no samples)")
        continue
    print(f"{name:<10} {r['cap']:5.1f} {r['ramp']:5.1f} | {r['cs']:6.1f} {r['cw']:6.1f} {r['cst']:6.1f} {r['cg']:6.1f} | {r['arr']:6.1f} {r['take']:8.1f} |"
          f" {r['seats']:5.1f}/{r['n']:<3d} ({r['seats'] / r['n']:4.0%}) {r['full']:4.0%} {r['door']:4.0%} | {r['passed']:6d} {r['fw']:5.1f} {r['gl']:5.2f} {r['lu']:6d}")
