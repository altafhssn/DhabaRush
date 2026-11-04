"""Summarise [d4] probe lines of one or more logs. Usage: d4_an.py [--from S] [--to S] [--bins S] LOG..."""
import re
import sys

args = sys.argv[1:]
t_from, t_to, bins = 60.0, 1e9, 0.0
while args and args[0].startswith("--"):
    k = args.pop(0)
    v = float(args.pop(0))
    if k == "--from":
        t_from = v
    elif k == "--to":
        t_to = v
    elif k == "--bins":
        bins = v

RX = re.compile(r"^\[d4\] t (?P<t>[\d.]+) seats (?P<su>\d+)/(?P<st>\d+) door (?P<door>\d+) room (?P<room>-?\d+) incoming (?P<inc>\d+) \| waiters (?P<wb>\d+)/(?P<wn>\d+) \| (?P<cooks>.*?)\| gallas (?P<gb>\d+)/(?P<gn>\d+) line (?P<gl>\d+) \| ramp (?P<ramp>[\d.-]+) raw (?P<raw>[\d.-]+) damp (?P<damp>[\d.]+) backlog (?P<bl>[\d.]+) \| cap seats (?P<cs>[\d.]+) waiters (?P<cw>[\d.]+) stations (?P<cst>[\d.]+) gallas (?P<cg>[\d.]+) hi (?P<hi>[\d.]+) \| rows (?P<rows>.*?)\| limit (?P<limit>\S*) capped (?P<capped>\S+) thr (?P<thr>[\d.]+) road (?P<road>[\d.]+) roomrate (?P<rr>[\d.]+) \| passed (?P<passed>\d+) arr (?P<arr>\d+)")
CK = re.compile(r"(\w+) (\d+)/(\d+) q(\d+) p(\d+)")


def mean(a):
    return sum(a) / len(a) if a else float("nan")


def summarise(samples, label):
    if not samples:
        print(label, "no samples")
        return
    n = len(samples)
    seat = [s["su"] / max(1, s["st"]) for s in samples]
    wait = [s["wb"] / max(1, s["wn"]) for s in samples]
    cook = [max((b / sl) for _, b, sl, _, _ in s["ck"]) if s["ck"] else 0 for s in samples]
    cookq = [sum(q for _, _, _, q, _ in s["ck"]) for s in samples]
    gal = [s["gb"] / max(1, s["gn"]) for s in samples]
    door = [s["door"] for s in samples]
    gl = [s["gl"] for s in samples]
    span = samples[-1]["t"] - samples[0]["t"]
    passed = samples[-1]["passed"] - samples[0]["passed"]
    arr = samples[-1]["arr"] - samples[0]["arr"]
    print(f"{label}: {n} samples, t {samples[0]['t']:.0f}-{samples[-1]['t']:.0f} s")
    print(f"  real busy (mean, share of samples >=90%): seats {mean(seat)*100:.0f}% ({sum(x>=0.9 for x in seat)/n*100:.0f}%), "
          f"waiters {mean(wait)*100:.0f}% ({sum(x>=0.9 for x in wait)/n*100:.0f}%), "
          f"busiest cook slot {mean(cook)*100:.0f}% ({sum(x>=0.9 for x in cook)/n*100:.0f}%), "
          f"cashiers {mean(gal)*100:.0f}% ({sum(x>=0.9 for x in gal)/n*100:.0f}%)")
    print(f"  seats full (all taken) {sum(s['su']>=s['st'] for s in samples)/n*100:.0f}% of samples; door line >0 {sum(d>0 for d in door)/n*100:.0f}% (max {max(door)}); "
          f"kitchen queue >0 {sum(q>0 for q in cookq)/n*100:.0f}% (mean {mean(cookq):.1f}, max {max(cookq)}); galla line >0 {sum(x>0 for x in gl)/n*100:.0f}% (max {max(gl)})")
    any90 = sum((a >= 0.9 or b >= 0.9 or c >= 0.9) for a, b, c in zip(seat, wait, gal)) / n
    print(f"  any of seats/waiters/cashiers >=90% busy: {any90*100:.0f}% of samples; arrivals {arr} = {arr*60/max(1,span):.1f}/min; drove past {passed} riders")
    print(f"  ramp mean {mean([s['ramp'] for s in samples]):.2f}/min (raw {mean([s['raw'] for s in samples]):.2f}), damp mean {mean([s['damp'] for s in samples]):.2f} min {min(s['damp'] for s in samples):.2f}, backlog mean {mean([s['bl'] for s in samples]):.1f} s")
    print(f"  capacity est: seats {mean([s['cs'] for s in samples]):.1f} waiters {mean([s['cw'] for s in samples]):.1f} stations {mean([s['cst'] for s in samples]):.1f} gallas {mean([s['cg'] for s in samples]):.1f} road {mean([s['hi'] for s in samples]):.1f}")
    # readout rows
    rows = {}
    for s in samples:
        for st, u, lim in s["rows"]:
            rows.setdefault(st, []).append(u)
    rs = ", ".join(f"{k} {mean(v)*100:.0f}% (min {min(v)*100:.0f}, max {max(v)*100:.0f}; full>=99% {sum(x>=0.99 for x in v)/len(v)*100:.0f}%)" for k, v in rows.items())
    print(f"  meter bars: {rs}")
    lims = {}
    for s in samples:
        k = "road" if s["capped"] == "true" else (s["limit"] or "-")
        lims[k] = lims.get(k, 0) + 1
    print("  meter limit: " + ", ".join(f"{k} {v/n*100:.0f}%" for k, v in sorted(lims.items(), key=lambda x: -x[1])))
    print(f"  any bar full (>=99%): {sum(any(u>=0.99 for _,u,_ in s['rows']) for s in samples)/n*100:.0f}% of samples")


def load(path):
    out = []
    for line in open(path, encoding="utf-8", errors="replace"):
        m = RX.match(line)
        if not m:
            continue
        d = m.groupdict()
        s = {k: (float(v) if k in ("t", "ramp", "raw", "damp", "bl", "cs", "cw", "cst", "cg", "hi", "thr", "road", "rr") else v) for k, v in d.items()}
        for k in ("su", "st", "door", "room", "inc", "wb", "wn", "gb", "gn", "gl", "passed", "arr"):
            s[k] = int(d[k])
        s["ck"] = [(a, int(b), int(c), int(q), int(p)) for a, b, c, q, p in CK.findall(d["cooks"])]
        s["rows"] = [(a, float(b), c == "*") for a, b, c in re.findall(r"(\w+) ([\d.]+)(\*?)", d["rows"])]
        out.append(s)
    return out


for p in args:
    ss = [s for s in load(p) if t_from <= s["t"] <= t_to]
    if bins > 0 and ss:
        t0 = ss[0]["t"]
        b = []
        cur = []
        for s in ss:
            if s["t"] - t0 >= bins:
                b.append(cur)
                cur = []
                t0 = s["t"]
            cur.append(s)
        if cur:
            b.append(cur)
        for c in b:
            summarise(c, f"{p.split('/')[-1]} bin")
    else:
        summarise(ss, p.split("/")[-1])
