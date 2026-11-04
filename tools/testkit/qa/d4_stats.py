"""Table of [stats] lines: t, seats, door, passed, ramp, caps, station queues, food wait. Usage: d4_stats.py LOG [from_s]"""
import re, sys
p = sys.argv[1]; t0 = float(sys.argv[2]) if len(sys.argv) > 2 else 0.0
cur = {}
rows = []
for line in open(p, encoding="utf-8", errors="replace"):
    m = re.match(r"\[stats\] ([\d.]+) cash [\d.]+ sales \d+ trav \d+ inside \d+ seats (\d+)/(\d+) door (\d+) .*?foodwait ([\d.-]+).*?passed (\d+)", line)
    if m:
        cur = {"t": float(m[1]), "su": int(m[2]), "st": int(m[3]), "door": int(m[4]), "fw": float(m[5]), "passed": int(m[6])}
        continue
    m = re.match(r"\[stats\]\s+ramp ([\d.]+)/min \(raw ([\d.]+).*capacity seats ([\d.]+) waiters ([\d.]+) stations ([\d.]+) gallas ([\d.]+).*backlog ([\d.]+) s damp ([\d.]+)", line)
    if m and cur:
        cur.update(ramp=float(m[1]), seats=float(m[3]), waiters=float(m[4]), stations=float(m[5]), gallas=float(m[6]), bl=float(m[7]), damp=float(m[8]))
        continue
    m = re.match(r"\[stats\]\s+stations: (.*)", line)
    if m and cur:
        cur["q"] = " ".join(f"{a}:{b}" for a, b in re.findall(r"(\w+) q (\d+)", m[1]))
        continue
    m = re.match(r"\[stats\]\s+arrivals \d+ .*?last \d+ s: ([\d.]+)/min", line)
    if m and cur:
        cur["arr"] = float(m[1])
        if cur["t"] >= t0:
            rows.append(cur)
        cur = {}
print("   t | seats | door | passed | ramp | arr/min(last) | cap seats waiters stations gallas | min | kitchen q | foodwait | backlog damp")
for r in rows:
    mn = min(r.get("seats", 0), r.get("waiters", 0), r.get("stations", 0) * 0.9, r.get("gallas", 0))
    print(f"{r['t']:5.0f} | {r['su']:2d}/{r['st']:2d} | {r['door']:4d} | {r['passed']:6d} | {r.get('ramp',0):4.1f} | {r.get('arr',0):5.1f} | {r.get('seats',0):5.1f} {r.get('waiters',0):5.1f} {r.get('stations',0):5.1f} {r.get('gallas',0):5.1f} | {mn:5.1f} | {r.get('q','')} | {r['fw']:5.1f} | {r.get('bl',0):5.1f} {r.get('damp',0):.2f}")
if rows:
    print(f"mean seats used {sum(r['su']/r['st'] for r in rows)/len(rows)*100:.0f}%, door>0 in {sum(r['door']>0 for r in rows)} of {len(rows)}, passed {rows[-1]['passed']-rows[0]['passed']}")
