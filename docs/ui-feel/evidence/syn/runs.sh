#!/bin/bash
# Synthesis re-runs. Usage: runs.sh BATCH   (1, 2, 3 or tut). Logs: design_work/syn/logs/<name>.log
# Slots (all QA copies; never the real project):
#   syn_a1..4 = today + GA's patch_pkg.py + syn_patch.py (--syn-gbk) + GA's probe (ga_probe.gd)
#   syn_b1..4 = today + GA's patch_pkg.py + syn_patch.py + GB's probe (gb_probe.gd: pick ranker, nudge model, follower)
#   syn_c1..4 = syn_a + P3 in the slot's economy copy (signboard.tpm_per_level 1.5 -> 3.5)
# With no --ga-*/--syn-* flag each slot runs today's game.
Q=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa
L=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/design_work/syn/logs
mkdir -p "$L"
PKG="--ga-k=1.2 --ga-rush=1.5 --ga-cashline=4 --ga-cue-all --ga-dampmin=1"   # GA's whole package (sim side)
NR="--ga-k=1.2 --ga-cashline=4 --ga-cue-all --ga-dampmin=1"                  # the same without the dinner rush
GBD="--syn-gbk=1.15 --ga-cue-all"                                           # GB-10 as designed (+ every drive-past cued)
NEWB="tandoor,galla,waiter,table,chai_lvl12,chai_speed,galla_up"
MIDB="waiter,waiter,tandoor,lassi,table,chai_lvl30,tandoor_lvl26,lassi_lvl12"
FULLB="waiter,waiter,tandoor,lassi,kadai,table,table,table,chai_lvl60,tandoor_lvl55,lassi_lvl52,kadai_lvl30"
# GA's setups (measured 60-905 s)
GCOM="--fresh --skip-tutorial --no-notes --stats=60 --d4-every=1 --quit-at=905"
G_NEW="$GCOM --money=1000 --buy=$NEWB --speed=2 --window=300"
G_MID="$GCOM --money=2000 --buy=$MIDB --window=840"
G_FULL="$GCOM --money=20000 --buy=$FULLB --signboard=1 --claims=25 --window=840"
G_FULLG="$GCOM --money=20000 --buy=$FULLB,galla --signboard=1 --claims=25 --window=840"
G_FULLG2="$GCOM --money=20000 --buy=$FULLB,galla --signboard=2 --claims=25 --window=840"
# GB's newcomer setup (measured 2-620 s)
B_NEW="--fresh --skip-tutorial --buy=$NEWB --no-notes --speed=2 --stats=60 --window=600 --d4-every=1 --quit-at=620"
TUT="--fresh --auto --window=600 --stats=120 --quit-at=820"

BATCH="$1"
JOBS=()
add() { JOBS+=("$*"); }   # add PREFIX NAME args...
case "$1" in
1)
  add syn_a idn_base_NEW_s1 $G_NEW --seed=1
  add syn_a idn_pkg_NEW_s1 $G_NEW --seed=1 $PKG
  for st in NEW MID FULL; do
    for s in 1 2 3 4; do
      v=G_$st; add syn_a nr_${st}_s$s ${!v} --seed=$s $NR
    done
  done
  for s in 1 2 3 4; do add syn_a gbd_NEW_s$s $G_NEW --seed=$s $GBD; done
  for s in 1 2; do add syn_a nr_FULLG_s$s $G_FULLG --seed=$s $NR; done
  ;;
2)
  for s in 1 2; do
    add syn_c p3pkg_FULLG1_s$s $G_FULLG --seed=$s $PKG
    add syn_c p3pkg_FULLG2_s$s $G_FULLG2 --seed=$s $PKG
    add syn_c p3base_FULLG2_s$s $G_FULLG2 --seed=$s
  done
  for s in 1 2; do add syn_a pkg_FULLG2_s$s $G_FULLG2 --seed=$s $PKG; done
  ;;
3)
  for s in 1 2 3 4; do add syn_b fol_pkg_s$s $B_NEW --money=394 --seed=$s --gb-follow=pick $PKG; done
  for s in 1 2; do add syn_b fol_nr_s$s $B_NEW --money=394 --seed=$s --gb-follow=pick $NR; done
  for s in 1 2; do add syn_b idle394_pkg_s$s $B_NEW --money=394 --seed=$s $PKG; done
  ;;
4)
  for s in 3 4; do
    add syn_a base_FULLG_s$s $G_FULLG --seed=$s
    add syn_a pkg_FULLG_s$s $G_FULLG --seed=$s $PKG
    add syn_a nr_FULLG_s$s $G_FULLG --seed=$s $NR
  done
  for s in 1 2; do add syn_c p3base_FULLG1_s$s $G_FULLG --seed=$s; done
  for s in 3 4; do add syn_c p3pkg_FULLG1_s$s $G_FULLG --seed=$s $PKG; done
  ;;
tut)
  for s in 1 2 3 4; do add syn_a tut_en_s$s $TUT --seed=$s $PKG; done
  ;;
esac

# run 4 at a time; job k of a group uses copy k (PREFIX1..4)
i=0
for j in "${JOBS[@]}"; do
  set -- $j
  pre=$1; name=$2; shift 2
  if [ $i -ge 4 ]; then wait; i=0; fi
  i=$(( i + 1 ))
  slot=$pre$i

  ( $Q/run.sh $slot "$L/$name.log" 600 -- "$@"; echo "$name $(tail -1 $L/$name.log) errs $(grep -c 'SCRIPT ERROR' $L/$name.log)" ) &
  sleep 0.3
done
wait
echo "BATCH $BATCH DONE"
