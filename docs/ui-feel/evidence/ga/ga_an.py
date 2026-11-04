"""GA analysis of probe logs ([d4] lines from ga_probe.gd, plus [sim]/[window] lines).
Usage: ga_an.py [--from S] [--to S] [--split] [--csv] LOG...
Per log (samples with --from <= t <= --to, default 60..905):
  full%    share of samples with every seat taken
  door     door line mean / max;  door>0 share
  cash     cashier line max (and mean)
  kq       kitchen queue max (tickets queued, all counters)
  tpm      takings in on-screen Rs/min (probe sales, x10), sales only
  fw       mean food wait (s) over the span (probe cumulative sum / n), fwmax (run max)
  arr      arrivals / min;  passed riders (span, from Game.passed_session)
  sent/cued/dropped  drive-past lines in the whole log ([sim] pass sent / drove past / cue dropped)
  meter    today's meter: limit row shares (road / seats / cooks / waiters / cashiers), any bar >= 99 %
  honest   GA-4 meter (5-s mean of live load): any row >= 100 % share, top row shares
  ready    plates READY on passes: mean / max (A8 opportunity)
--split prints the same for rush and off-peak samples (rush flag from the probe).
"""
import re
import sys

RX = re.compile(r"^\[d4\] t (?P<t>[\d.]+) seats (?P<su>\d+)/(?P<st>\d+) door (?P<door>\d+) room (?P<room>-?\d+) incoming (?P<inc>\d+) \| waiters (?P<wb>\d+)/(?P<wn>\d+) \| (?P<cooks>.*?)\| gallas (?P<gb>\d+)/(?P<gn>\d+) line (?P<gl>\d+) \| ramp (?P<ramp>[\d.-]+) raw (?P<raw>[\d.-]+) damp (?P<damp>[\d.]+) backlog (?P<bl>[\d.]+) \| cap seats (?P<cs>[\d.]+) waiters (?P<cw>[\d.]+) stations (?P<cst>[\d.]+) gallas (?P<cg>[\d.]+) hi (?P<hi>[\d.]+) \| rows (?P<rows>.*?)\| limit (?P<limit>\S*) capped (?P<capped>\S+) thr (?P<thr>[\d.]+) road (?P<road>[\d.]+) roomrate (?P<rr>[\d.]+) \| passed (?P<passed>\d+) arr (?P<arr>\d+) \| sales (?P<sales>[\d.]+) paid (?P<paid>\d+) fw (?P<fws>[\d.]+) (?P<fwn>\d+) fwmax (?P<fwmax>[\d.]+) \| phase (?P<phase>[\d.]+) rush (?P<rush>\d) hold (?P<hold>[\d.]+) \| ready (?P<ready>\d+) station (?P<station>\S*)(?: wpay (?P<wpay>\d+))?")
CK = re.compile(r"(\w+) (\d+)/(\d+) q(\d+) p(\d+)")
FLOATS = ("t", "ramp", "raw", "damp", "bl", "cs", "cw", "cst", "cg", "hi", "thr", "road", "rr", "sales", "fws", "fwmax", "phase", "hold")


def load(path):
    out = []
    sent = cued = dropped = sent_riders = 0
    win = ""
    for line in open(path, encoding="utf-8", errors="replace"):
        if line.startswith("[sim] pass sent:"):
            sent += 1
            m = re.search(r"pass sent: \S* ?(\d+)", line)
            if m:
                sent_riders += int(m.group(1))
            continue
        if line.startswith("[sim] drove past:"):
            cued += 1
            continue
        if line.startswith("[sim] drive-past cue dropped"):
            dropped += 1
            continue
        if line.startswith("[window]") and "takings" in line:
            win = line.strip()
            continue
        m = RX.match(line)
        if not m:
            continue
        d = m.groupdict()
        s = {}
        for k, v in d.items():
            if k in FLOATS:
                s[k] = float(v)
            elif k in ("cooks", "rows", "limit", "capped", "station"):
                s[k] = v
            elif k == "wpay":
                s[k] = int(v) if v is not None else 0
            else:
                s[k] = int(v)
        s["ck"] = [(a, int(b), int(c), int(q), int(p)) for a, b, c, q, p in CK.findall(d["cooks"])]
        s["rowsp"] = [(a, float(b), c == "*") for a, b, c in re.findall(r"(\w+) ([\d.]+)(\*?)", d["rows"])]
        out.append(s)
    prev = None
    for s in out:
        for k in ("sales", "arr", "fws", "fwn", "passed", "t"):
            s["d_" + k] = (s[k] - prev[k]) if prev is not None else 0
        prev = s
    return out, dict(sent=sent, cued=cued, dropped=dropped, sent_riders=sent_riders, window=win)


def honest_rows(s):
    """GA-4 rows: (busy share 0..1, waiting per slot). SEATS: seats taken, door line; COOKS: the counter
    with the most work per cook: busy cooks, orders queued per cook; WAITERS: busy waiters, plates READY
    per waiter; CASHIERS: busy cashiers, bill line + diners waiting to pay, per counter."""
    if s["ck"]:
        a, b, sl, q, _ = max(s["ck"], key=lambda c: (c[1] + c[3]) / max(1, c[2]))
        cook = (b / max(1, sl), q / max(1, sl))
    else:
        cook = (0.0, 0.0)
    return {"seats": (s["su"] / max(1, s["st"]), float(s["door"])),
            "cooks": cook,
            "waiters": (s["wb"] / max(1, s["wn"]), s["ready"] / max(1, s["wn"])),
            "cashiers": (s["gb"] / max(1, s["gn"]), (s["gl"] + s.get("wpay", 0)) / max(1, s["gn"]))}


# Overflow thresholds (waiting per slot, 5-s mean) = what the GA-4 bar marks red with a "+n":
# a door line of 1+, 2+ orders queued per cook, 1+ plate waiting per waiter, 3+ in line per cash counter
# (= next_chip.gd's LONG BILL LINE at an average line of 3).
OVER = {"seats": 1.0, "cooks": 2.0, "waiters": 1.0, "cashiers": 3.0}


def mean(a):
    return sum(a) / len(a) if a else float("nan")


def summarise(ss, extra, label, show_drive=True):
    if len(ss) < 2:
        print(f"{label}: no samples")
        return {}
    n = len(ss)
    span = sum(s["d_t"] for s in ss[1:]) if ss else 0.0
    full = sum(s["su"] >= s["st"] for s in ss) / n * 100
    door = [s["door"] for s in ss]
    gl = [s["gl"] for s in ss]
    kq = [sum(q for _, _, _, q, _ in s["ck"]) for s in ss]
    body = ss[1:]
    tpm = sum(s["d_sales"] for s in body) * 60.0 / max(1.0, span) * 10.0
    fwn = sum(s["d_fwn"] for s in body)
    fw = sum(s["d_fws"] for s in body) / max(1, fwn)
    arr = sum(s["d_arr"] for s in body) * 60.0 / max(1.0, span)
    passed = sum(s["d_passed"] for s in body)
    lim = {}
    for s in ss:
        k = "road" if s["capped"] == "true" else (s["limit"] or "-")
        lim[k] = lim.get(k, 0) + 1
    anybar = sum(any(u >= 0.99 for _, u, _ in s["rowsp"]) for s in ss) / n * 100
    # GA-4 meter: 5-sample moving means; "full" = a row 95 %+ busy; "overflow" = waiting past OVER
    hr = [honest_rows(s) for s in ss]
    sm = []
    for i in range(n):
        w = hr[max(0, i - 4): i + 1]
        sm.append({k: (mean([x[k][0] for x in w]), mean([x[k][1] for x in w])) for k in hr[0]})
    hfull = sum(any(v[0] >= 0.95 for v in x.values()) for x in sm) / n * 100
    hover = sum(any(x[k][1] >= OVER[k] for k in x) for x in sm) / n * 100
    top = {}
    for x in sm:
        ks = [k for k in x if x[k][1] >= OVER[k]]
        if ks:
            k = max(ks, key=lambda kk: x[kk][1] / OVER[kk])
            top[k] = top.get(k, 0) + 1
    ready = [s["ready"] for s in ss]
    res = dict(n=n, span=span, full=full, door_mean=mean(door), door_max=max(door), door_pos=sum(d > 0 for d in door) / n * 100,
               cash_max=max(gl), cash_mean=mean(gl), kq_max=max(kq), kq_mean=mean(kq), tpm=tpm, fw=fw, arr=arr, passed=passed,
               lim={k: v / n * 100 for k, v in lim.items()}, anybar=anybar, hfull=hfull, hover=hover, top={k: v / n * 100 for k, v in top.items()},
               ready_mean=mean(ready), ready_max=max(ready), ramp=mean([s["ramp"] for s in ss]), damp=mean([s["damp"] for s in ss]))
    lims = ", ".join(f"{k} {v:.0f}%" for k, v in sorted(res["lim"].items(), key=lambda kv: -kv[1]))
    tops = ", ".join(f"{k} {v:.0f}%" for k, v in sorted(res["top"].items(), key=lambda kv: -kv[1])) or "none"
    print(f"{label}: {n} samples t {ss[0]['t']:.0f}-{ss[-1]['t']:.0f} | full {full:.0f}% | door mean {res['door_mean']:.2f} max {res['door_max']} (>0 {res['door_pos']:.0f}%) "
          f"| cash line max {res['cash_max']} mean {res['cash_mean']:.1f} | kitchen q max {res['kq_max']} mean {res['kq_mean']:.1f} | Rs {tpm:.0f}/min | food wait {fw:.1f} s "
          f"| arr {arr:.1f}/min ramp {res['ramp']:.1f} damp {res['damp']:.2f} | passed {passed} riders | meter limit: {lims}; any bar>=99% {anybar:.0f}% "
          f"| GA-4 a row 95%+ busy {hfull:.0f}%, a row overflowing {hover:.0f}% (top: {tops}) | ready plates mean {res['ready_mean']:.1f} max {res['ready_max']}")
    if show_drive:
        print(f"   drive-pasts in the whole log: sent {extra['sent']} ({extra['sent_riders']} riders), cued {extra['cued']}, dropped {extra['dropped']} | fwmax {ss[-1]['fwmax']:.1f} s")
        if extra["window"]:
            print("   " + extra["window"][:260])
    return res


if __name__ == "__main__":
    args = sys.argv[1:]
    t_from, t_to, split = 60.0, 1e9, False
    while args and args[0].startswith("--"):
        k = args.pop(0)
        if k == "--split":
            split = True
            continue
        v = float(args.pop(0))
        if k == "--from":
            t_from = v
        elif k == "--to":
            t_to = v
    for p in args:
        ss, extra = load(p)
        ss = [s for s in ss if t_from <= s["t"] <= t_to]
        name = p.split("/")[-1]
        summarise(ss, extra, name)
        if split:
            r = [s for s in ss if s["rush"] == 1]
            o = [s for s in ss if s["rush"] == 0]
            # contiguous rush runs: summarise each block's share with the samples as is
            summarise(r, extra, "   rush    ", False) if len(r) > 1 else print("   rush: none")
            summarise(o, extra, "   off-peak", False)
