#!/bin/bash
# PROG pacing runs (4 Nov 2026). Every run: pacing_prog.py --promo --minutes 110 --gaps (100 for the today rows
# is enough, 110 lets late ad tiers show). pacing_prog.py = tools/sim/pacing_v3.py + pacing_prog.diff; without --prog
# it prints exactly what the real tool prints (checked: diff against today_promo100.txt, 0 lines).
# Design JSON: prog_design.json (= variants/cand.json). Variants: variants/<name>.json. Outputs: final/<name>.txt
P=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/design_work/prog
PY=/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13
cd $P && mkdir -p final variants
mk() { $PY -I -B - "$@" <<'PYX'
import json, sys
name, ov = sys.argv[1], sys.argv[2]
d = json.load(open("prog_design.json"))
for kv in [x for x in ov.split(";") if x.strip()]:
    path, val = kv.split("=", 1)
    node = d
    ks = path.split(".")
    for k in ks[:-1]:
        node = node[int(k)] if isinstance(node, list) else node[k]
    if isinstance(node, list):
        node[int(ks[-1])] = json.loads(val)
    else:
        node[ks[-1]] = json.loads(val)
json.dump(d, open(f"variants/{name}.json", "w"), indent=2)
PYX
}
PKG="--rush 1.5 --set traffic.ramp_capacity_k=1.05 --set signboard.tpm_per_level=3.5 --realized 0.943"
PKGNO13="--rush 1.5 --set traffic.ramp_capacity_k=1.05 --realized 0.943"
mk D_honest "ad_gain_staffed=0"
mk D_camp "campaign.enabled=true"
mk D_allreset "ads.1.carry=false;ads.2.carry=false"
mk D_allcarry "ads_reset_on_move=false"
mk D_nonews "ads.0.tables=6;ads.1.tables=7;ads.2.tables=8;ads.3.tables=8"
mk D_notier 'table_costs_by_set={"3":30,"4":75,"5":180,"6":432,"7":1036.8,"8":2488.32};waiter_hire_costs=[40,120,360]'
R=(
 "T_today|"
 "T_noads|--no-ads"
 "T_r085|--realized 0.85"
 "T_pkg|$PKG"
 "D_design|--prog prog_design.json"
 "D_noads|--prog prog_design.json --no-ads"
 "D_r085|--prog prog_design.json --realized 0.85"
 "D_pkg|--prog prog_design.json $PKG"
 "D_pkg_noG13|--prog prog_design.json $PKGNO13"
 "D_G13|--prog prog_design.json --set signboard.tpm_per_level=3.5"
 "D_camp|--prog variants/D_camp.json"
 "D_pkg_camp|--prog variants/D_camp.json $PKG"
 "D_honest|--prog variants/D_honest.json"
 "D_allreset|--prog variants/D_allreset.json"
 "D_allcarry|--prog variants/D_allcarry.json"
 "D_nonews|--prog variants/D_nonews.json"
 "D_notier|--prog variants/D_notier.json"
)
i=0
for r in "${R[@]}"; do
  name=${r%%|*}; args=${r#*|}
  if [ $i -ge 6 ]; then wait; i=0; fi
  i=$((i+1))
  ( echo "CMD: $PY -I -B pacing_prog.py --promo --minutes 110 --gaps $args" > final/$name.txt;
    $PY -I -B pacing_prog.py --promo --minutes 110 --gaps $args >> final/$name.txt 2>&1; echo "$name rc=$?" ) &
done
wait
echo ALL DONE
# --- added after the first pass: half-size ad tiers (+1, +1.5, +2, +2.5 a minute), with and without G13
mkhalf() { :; }   # variants/D_halfads.json = prog_design.json with ads tpm 1 / 1.5 / 2 / 2.5
for r in "D_G13_halfads|--prog variants/D_halfads.json --set signboard.tpm_per_level=3.5" "D_halfads|--prog variants/D_halfads.json" "D_pkg_halfads|--prog variants/D_halfads.json $PKG"; do
  name=${r%%|*}; args=${r#*|}
  ( echo "CMD: $PY -I -B pacing_prog.py --promo --minutes 110 --gaps $args" > final/$name.txt;
    $PY -I -B pacing_prog.py --promo --minutes 110 --gaps $args >> final/$name.txt 2>&1; echo "$name rc=$?" ) &
done
wait
