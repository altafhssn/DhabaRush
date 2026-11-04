"""GB: one row per in-game log + the mean of each group (logs named <group>_s<seed>.log).
Reads the [d4] probe lines (qa/d4_an.py's regex), [window], [stats], [sim] pass/cue lines and
the [gb] lines. Usage: gb_stats.py [--from S] [--to S] LOG...   (money: screen rupees = ref x 10)
"""
import re, sys
from collections import defaultdict

args = sys.argv[1:]
t_from, t_to = 60.0, 1e9
while args and args[0].startswith("--"):
    k = args.pop(0); v = float(args.pop(0))
    if k == "--from": t_from = v
    elif k == "--to": t_to = v

RX = re.compile(r"^\[d4\] t (?P<t>[\d.]+) seats (?P<su>\d+)/(?P<st>\d+) door (?P<door>\d+) room (?P<room>-?\d+) incoming (?P<inc>\d+) \| waiters (?P<wb>\d+)/(?P<wn>\d+) \| (?P<cooks>.*?)\| gallas (?P<gb>\d+)/(?P<gn>\d+) line (?P<gl>\d+) \| ramp (?P<ramp>[\d.-]+) raw (?P<raw>[\d.-]+) damp (?P<damp>[\d.]+) backlog (?P<bl>[\d.]+) \| cap seats (?P<cs>[\d.]+) waiters (?P<cw>[\d.]+) stations (?P<cst>[\d.]+) gallas (?P<cg>[\d.]+) hi (?P<hi>[\d.]+) \| rows (?P<rows>.*?)\| limit (?P<limit>\S*) capped (?P<capped>\S+) thr (?P<thr>[\d.]+) road (?P<road>[\d.]+) roomrate (?P<rr>[\d.]+) \| passed (?P<passed>\d+) arr (?P<arr>\d+)")
CK = re.compile(r"(\w+) (\d+)/(\d+) q(\d+) p(\d+)")


def one(path):
    S = []
    out = {"window": None}
    sent = cued = dropped = 0
    gb = defaultdict(int)
    stats_cash = {}
    for line in open(path, encoding="utf-8", errors="replace"):
        m = RX.match(line)
        if m:
            t = float(m["t"])
            if t_from <= t <= t_to:
                ck = [(a, int(b), int(c), int(q)) for a, b, c, q, p in CK.findall(m["cooks"])]
                S.append(dict(t=t, su=int(m["su"]), st=int(m["st"]), door=int(m["door"]), gl=int(m["gl"]),
                              gb=int(m["gb"]), gn=int(m["gn"]), wb=int(m["wb"]), wn=int(m["wn"]),
                              kq=sum(q for _, _, _, q in ck), cook=max((b / c) for _, b, c, _ in ck) if ck else 0.0,
                              limit=("road" if m["capped"] == "true" else (m["limit"] or "-")),
                              passed=int(m["passed"]), arr=int(m["arr"]),
                              rows=dict((a, float(b)) for a, b, _ in re.findall(r"(\w+) ([\d.]+)(\*?)", m["rows"]))))
            continue
        if line.startswith("[window]") and "after start" in line:
            w = re.search(r"arrivals (\d+) = ([\d.]+)/min .*?passed (\d+) \| takings ([\d.]+)/min \| food wait mean ([\d.]+) s .*?max ([\d.]+) s", line)
            if w:
                out["window"] = dict(arr=float(w[2]), passed=int(w[3]), tak=float(w[4]) * 10, fw=float(w[5]), fwmax=float(w[6]))
        elif line.startswith("[sim] pass sent"):
            sent += 1
        elif line.startswith("[sim] drove past:"):
            cued += 1
        elif line.startswith("[sim] drive-past cue dropped"):
            dropped += 1
        elif line.startswith("[gb] "):
            k = line.split()[1]
            gb[k] += 1
            if k == "follow" and "-> true" in line:
                gb["bought"] += 1
        sm = re.match(r"\[stats\] ([\d.]+) cash ([\d.]+) ", line)
        if sm:
            stats_cash[round(float(sm[1]))] = float(sm[2])
    n = max(1, len(S))
    if S:
        span = S[-1]["t"] - S[0]["t"]
        out.update(
            n=len(S),
            full=100.0 * sum(s["su"] >= s["st"] for s in S) / n,
            seats=100.0 * sum(s["su"] / max(1, s["st"]) for s in S) / n,
            door_mean=sum(s["door"] for s in S) / n, door_max=max(s["door"] for s in S),
            door_pos=100.0 * sum(s["door"] > 0 for s in S) / n,
            gl_max=max(s["gl"] for s in S), gl_mean=sum(s["gl"] for s in S) / n,
            kq_max=max(s["kq"] for s in S), kq_mean=sum(s["kq"] for s in S) / n,
            cook=100.0 * sum(s["cook"] for s in S) / n,
            waiters=100.0 * sum(s["wb"] / max(1, s["wn"]) for s in S) / n,
            cashiers=100.0 * sum(s["gb"] / max(1, s["gn"]) for s in S) / n,
            passed=S[-1]["passed"] - S[0]["passed"], arr_pm=(S[-1]["arr"] - S[0]["arr"]) * 60.0 / max(1.0, span),
            any_full_bar=100.0 * sum(any(u >= 0.99 for u in s["rows"].values()) for s in S) / n,
        )
        lims = defaultdict(int)
        for s in S:
            lims[s["limit"]] += 1
        out["limits"] = ", ".join(f"{k} {100.0*v/n:.0f}%" for k, v in sorted(lims.items(), key=lambda x: -x[1]))
    out.update(sent=sent, cued=cued, dropped=dropped, gb=dict(gb), cash=stats_cash)
    return out


groups = defaultdict(list)
for p in args:
    name = p.split("/")[-1].rsplit(".", 1)[0]
    g = re.sub(r"_s\d+$", "", name)
    r = one(p)
    groups[g].append((name, r))
    w = r["window"] or {}
    print(f"{name}: full {r.get('full',0):.0f}% seats {r.get('seats',0):.0f}% door mean {r.get('door_mean',0):.2f} max {r.get('door_max',0)} (>0 {r.get('door_pos',0):.0f}%) "
          f"| bill line max {r.get('gl_max',0)} mean {r.get('gl_mean',0):.1f} | kitchen q max {r.get('kq_max',0)} mean {r.get('kq_mean',0):.1f} "
          f"| busy cook {r.get('cook',0):.0f}% waiters {r.get('waiters',0):.0f}% cashiers {r.get('cashiers',0):.0f}% "
          f"| sent {r['sent']} cued {r['cued']} dropped {r['dropped']} riders {r.get('passed',0)} "
          f"| window tak Rs {w.get('tak',0):.0f}/min arr {w.get('arr',0):.1f}/min fw {w.get('fw',0):.1f} s (max {w.get('fwmax',0):.0f}) "
          f"| limit {r.get('limits','')} | full bar {r.get('any_full_bar',0):.0f}% | gb {r['gb']}")

print("\n== group means (seeds)")
for g, rs in groups.items():
    def m(k, sub=None):
        vals = [(r[sub] or {}).get(k, 0) if sub else r.get(k, 0) for _, r in rs]
        return sum(vals) / len(vals)
    def mx(k):
        return max(r.get(k, 0) for _, r in rs)
    taks = [(r["window"] or {}).get("tak", 0) for _, r in rs]
    print(f"{g} (n={len(rs)}): full {m('full'):.0f}% | seats {m('seats'):.0f}% | door mean {m('door_mean'):.2f} max {mx('door_max')} (>0 {m('door_pos'):.0f}%) "
          f"| bill line max {mx('gl_max')} | kitchen q max {mx('kq_max')} | sent {m('sent'):.1f} cued {m('cued'):.1f} riders {m('passed'):.1f} "
          f"| takings Rs {m('tak','window'):.0f}/min (seeds {', '.join(f'{x:.0f}' for x in taks)}) | food wait {m('fw','window'):.1f} s "
          f"| arr {m('arr','window'):.1f}/min | busy cook {m('cook'):.0f}% waiters {m('waiters'):.0f}% cashiers {m('cashiers'):.0f}% | full bar {m('any_full_bar'):.0f}%")
