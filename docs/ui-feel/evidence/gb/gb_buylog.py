"""GB copy of D2's buylog.py with --set PATH=VALUE and --realized R (eco overrides, like pacing_v3.py).
d2 agency: instrument tools/sim/pacing_v3.py (read-only import) and log every purchase
of the greedy part-B bot, with time, kind, cost, and the steady-state income change.
Usage: python3 -I -B buylog.py [--minutes 30] [--no-ads] [--out FILE.json]
"""
import importlib.util, sys, io, contextlib, json, math, argparse

PV = "/Users/almeer/Documents/HighwayDhaba/tools/sim/pacing_v3.py"
spec = importlib.util.spec_from_file_location("pv3", PV)
pv = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pv)

ap = argparse.ArgumentParser()
ap.add_argument("--minutes", type=float, default=30.0)
ap.add_argument("--no-ads", action="store_true")
ap.add_argument("--out", default="")
ap.add_argument("--set", action="append", default=[])
ap.add_argument("--realized", type=float, default=None)
ap.add_argument("--gb-k", type=float, default=None)
args = ap.parse_args()

STATE = {"on": False, "t": 0.0, "model": None}
BUYS = []
REWARDS = []
TICKS = []   # (t, cash_before_act, cheapest_any, cheapest_level, bought_n)


def steady(g):
    c = pv.capacity(g)
    return c["target"] * g.basket(), c["bind"]


orig_buy = pv.SeatedGame.buy


def buy(self, kind, arg=None):
    if not STATE["on"]:
        return orig_buy(self, kind, arg)
    cash0 = self.cash
    inc0, bind0 = steady(self)
    lv0 = self.st[arg]["level"] if kind == "level" else None
    ok = orig_buy(self, kind, arg)
    if ok:
        inc1, bind1 = steady(self)
        rec = dict(t=STATE["t"], kind=kind, arg=arg, cost=cash0 - self.cash, inc0=inc0, inc1=inc1,
                   bind0=bind0, bind1=bind1)
        if kind == "level":
            rec["level"] = lv0 + 1
        if kind == "waiter_up":
            rec["level"] = self.waiters[arg]
        BUYS.append(rec)
    return ok


pv.SeatedGame.buy = buy

orig_add_reward = pv.Game.add_reward


def add_reward(self, amount, source="task"):
    if STATE["on"]:
        REWARDS.append(dict(t=STATE["t"], source=source, amount=amount))
    return orig_add_reward(self, amount, source)


pv.Game.add_reward = add_reward


def cheapest(g):
    items = []
    lv = []
    for s in g.built():
        d = g.sdef(s)
        if g.st[s]["level"] < d["max_level"]:
            items.append(g.level_cost(s)); lv.append(g.level_cost(s))
        if g.st[s]["employees"] < d["employees_max"]:
            items.append(g.hire_cost(s))
        if g.st[s]["proc"] < d["processing_max"]:
            items.append(g.proc_cost(s))
    for i in range(len(g.gallas)):
        if g.gallas[i] < g.e["galla"]["max_level"]:
            items.append(g.galla_up_cost(i))
    if len(g.gallas) < g.e["galla"]["max"]:
        items.append(g.galla_hire_cost())
    if len(g.waiters) < g.waiters_max():
        items.append(g.waiter_hire_cost())
    for i in range(len(g.waiters)):
        if g.waiters[i] < g.e["waiters"]["max_level"]:
            items.append(g.waiter_up_cost(i))
    if g.tables < g.tables_max():
        items.append(g.table_cost())
    for s in g.station_ids():
        if not g.st[s]["built"] and g.can_build(s):
            items.append(g.build_cost(s))
            break
    if g.sign_on and g.sign < g.sign_max() and g.sign_unlocked():
        items.append(g.sign_cost())
    return (min(items) if items else math.inf), (min(lv) if lv else math.inf)


orig_act = pv.SeatedModel.act
orig_step = pv.SeatedModel.step


def act(self):
    STATE["t"] = self.t
    n0 = len(BUYS)
    ca, cl = cheapest(self.g)
    cash = self.g.cash
    sign0 = len(self.sign_log)
    stage0 = self.g.stage
    orig_act(self)
    TICKS.append((self.t, cash, ca, cl, len(BUYS) - n0 + (len(self.sign_log) - sign0) + (self.g.stage - stage0)))
    for (t, st, lvl, cost) in self.sign_log[sign0:]:
        BUYS.append(dict(t=t, kind="sign", arg=lvl, cost=cost, inc0=0, inc1=0, bind0="", bind1=""))


pv.SeatedModel.act = act

if args.gb_k is not None:
    K = args.gb_k
    _orig_cap = pv.capacity
    def _gb_capacity(g, built=None, plan_tandoor=False, sign_extra=0):
        c = _orig_cap(g, built, plan_tandoor, sign_extra)
        tr = g.e["traffic"]
        m_other = min(c["waiters"], c["seats"], c["stations"])
        hi = c["cap"]
        c["target"] = min(hi, max(tr["ramp_min_tpm"], min(K * m_other, c["gallas"])))
        if min(K * m_other, c["gallas"]) < hi:
            caps = {"waiters": K * c["waiters"], "seats": K * c["seats"], "stations": K * c["stations"], "gallas": c["gallas"]}
            b = min(caps, key=caps.get)
            if b == "stations":
                sh = c["shares"]
                b = "station:" + min(sh, key=lambda s2: g.capacity(s2) / max(1e-6, sh[s2]))
            c["bind"] = b
        else:
            c["bind"] = "max"
        return c
    pv.capacity = _gb_capacity
eco = json.loads(pv.ECO_PATH.read_text())
for kv in args.set:
    path, val = kv.split("=", 1)
    node = eco
    for k in path.split(".")[:-1]:
        node = node[k]
    node[path.split(".")[-1]] = json.loads(val)
pv.DISPLAY_SCALE[0] = float(eco.get("money_display_scale", 10.0))
buf = io.StringIO()
with contextlib.redirect_stdout(buf):
    runs = pv.part_a(eco, 8, True)
    built = [r for r in runs if r["game"].st["tandoor"]["built"]]
    run = built[0]
    pv.REPORT[0] = 120.0
    STATE["on"] = True
    opts = dict(promo=True)
    if args.realized is not None:
        opts["realized"] = args.realized
    m = pv.part_b(eco, run, args.minutes, not args.no_ads, opts)
out = dict(buys=BUYS, rewards=REWARDS, ticks=TICKS, minutes=args.minutes, ads=not args.no_ads,
           events=[(t, e) for t, e in m.events], marks=m.marks)
if args.out:
    with open(args.out, "w") as f:
        json.dump(out, f)
print(f"buys {len(BUYS)} rewards {len(REWARDS)} ticks {len(TICKS)}")
