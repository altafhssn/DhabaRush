"""GB pacing what-if: tools/sim/pacing_v3.py imported read-only, with GB-10's free-play k applied to
seats, waiters and the kitchen only (never the cashiers: P0 as designed). Usage: same args as pacing_v3.py,
plus --gb-k K (default 1.15)."""
import importlib.util, sys
PV = "/Users/almeer/Documents/HighwayDhaba/tools/sim/pacing_v3.py"
spec = importlib.util.spec_from_file_location("pv3", PV)
pv = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pv)
K = 1.15
argv = sys.argv[1:]
if "--gb-k" in argv:
    i = argv.index("--gb-k"); K = float(argv[i + 1]); del argv[i:i + 2]
orig = pv.capacity

def capacity(g, built=None, plan_tandoor=False, sign_extra=0):
    c = orig(g, built, plan_tandoor, sign_extra)
    tr = g.e["traffic"]
    m_other = min(c["waiters"], c["seats"], c["stations"])
    hi = c["cap"]
    target = min(hi, max(tr["ramp_min_tpm"], min(K * m_other, c["gallas"])))
    c["target"] = target
    # the binding stage under the GB rule ("max" = the road)
    if min(K * m_other, c["gallas"]) < hi:
        caps = {"waiters": K * c["waiters"], "seats": K * c["seats"], "stations": K * c["stations"], "gallas": c["gallas"]}
        b = min(caps, key=caps.get)
        if b == "stations":
            sh = c["shares"]
            b = "station:" + min(sh, key=lambda s: g.capacity(s) / max(1e-6, sh[s]))
        c["bind"] = b
    else:
        c["bind"] = "max"
    return c

pv.capacity = capacity
print(f"GB: free-play k {K} on seats, waiters and the kitchen; cashiers at 1.0")
sys.argv = [PV] + argv
pv.main()
