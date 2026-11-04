#!/bin/bash
# PROG in-game check (4 Nov 2026): how full does a Family Dhaba get when the ad ladder raises the road cap?
# Slots (QA copies only; never the real project): prog_a = today + GA's prototype patch (design_work/ga/patch_pkg.py:
# --ga-* flags, none = today's game), imported; prog_b = prog_a with signboard.tpm_per_level 1.5 -> 3.5 in the slot's
# data, so --signboard=N stands in for the ad ladder (cap 19.5 + 3.5 N: N=3 -> 30.0, N=6 -> 40.5).
# Sub-slots NAME__k (APFS clones) give each concurrent run its own save. Logs: ingame/logs/<name>.log
Q=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa
L=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/design_work/prog/ingame/logs
UPS=$(printf 'galla_up,%.0s' $(seq 1 19))
# a mid Family Dhaba (pacing bot near 54 min, cand design): counters L103-109 with 3 cooks, 4 waiters at L8, 7 table
# sets, cashiers at L20 and L1
BUY="chai_lvl103,tandoor_lvl104,lassi_lvl109,kadai_lvl103,chai_hire,chai_hire,tandoor_hire,tandoor_hire,lassi_hire,lassi_hire,kadai_hire,kadai_hire,waiter,waiter,waiter,table,table,table,table,galla,${UPS}waiter_lvl8"
COM="--fresh --skip-tutorial --no-notes --money=1000000000 --renovate --buy=$BUY --stats=10 --window=600 --quit-at=640"
G11="--ga-k=1.2 --ga-dampmin=1 --ga-cashline=4 --ga-cue-all"
JOBS=(
 "prog_a A21_s1 --signboard=1 --seed=1"
 "prog_a A21_s2 --signboard=1 --seed=2"
 "prog_b B30_s1 --signboard=3 --seed=1"
 "prog_b B30_s2 --signboard=3 --seed=2"
 "prog_b C40_s1 --signboard=6 --seed=1"
 "prog_b C40_s2 --signboard=6 --seed=2"
 "prog_b B30g_s1 --signboard=3 --seed=1 $G11"
 "prog_b B30g_s2 --signboard=3 --seed=2 $G11"
 "prog_b C40g_s1 --signboard=6 --seed=1 $G11"
 "prog_b C40g_s2 --signboard=6 --seed=2 $G11"
 "prog_a A21g_s1 --signboard=1 --seed=1 $G11"
)
i=0
for j in "${JOBS[@]}"; do
  set -- $j
  base=$1; name=$2; shift 2
  if [ $i -ge 4 ]; then wait; i=0; fi
  i=$(( i + 1 ))
  slot=${base}__$i
  [ -d "$Q/slots/$slot" ] || $Q/mkslot.sh $slot $Q/slots/$base/proj > /dev/null
  ( $Q/run.sh $slot "$L/$name.log" 900 -- $COM "$@"; echo "$name $(tail -1 $L/$name.log) errs $(grep -c 'SCRIPT ERROR' $L/$name.log)" ) &
  sleep 0.5
done
wait
echo ALL DONE
# --- batch 2 (run by hand, see runs2 below): prog_bx = prog_b with sim.gd BUS_LOAD_EXTRA_MAX 4 -> 12 in the slot
# (a bus may carry up to bus_riders_max + 12 = 18 riders), to test whether traffic delivery caps the ad ladder:
#   $Q/run.sh prog_bx__1 $L/C40x_s1.log 900 -- $COM --signboard=6 --seed=1
#   $Q/run.sh prog_bx__2 $L/C40gx_s1.log 900 -- $COM --signboard=6 --seed=1 $G11
