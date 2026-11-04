#!/bin/bash
# GB measurement batch (slot gb_m = the project + gb_probe.gd autoload + proto_sim.diff).
# No --gb-* sim flag = today's game. PKG = the package's sim parts (P1 k 1.15 in free play,
# P0 bill line takes room beyond 3 a cashier, P10 every drive-past cued).
Q=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa
W=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/design_work/gb
L=$W/logs
PKG="--gb-k=1.15 --gb-p0=3 --gb-cueall"
NEWB="tandoor,galla,waiter,table,chai_lvl12,chai_speed,galla_up"
NEW="--fresh --skip-tutorial --buy=$NEWB --no-notes --speed=2 --stats=60 --window=600 --d4-every=1 --quit-at=620"
MID="waiter,waiter,tandoor,lassi,table,chai_lvl30,tandoor_lvl26,lassi_lvl12"
FULL="waiter,waiter,tandoor,lassi,kadai,table,table,table,chai_lvl60,tandoor_lvl55,lassi_lvl52,kadai_lvl30"
COMMON="--fresh --skip-tutorial --no-notes --stats=30 --window=600 --d4-every=1 --quit-at=905"
job() { $Q/run.sh gb_m "$L/$1.log" 900 -- "${@:2}"; echo "$1 $(tail -1 $L/$1.log) errs $(grep -c 'SCRIPT ERROR' $L/$1.log)"; }
case "$1" in
new)
  for s in 1 2 3 4; do
    job new_idle_today_s$s $NEW --money=1000 --seed=$s &
    job new_idle_pkg_s$s $NEW --money=1000 --seed=$s $PKG &
    job new_chip_today_s$s $NEW --money=394 --seed=$s --gb-follow=chip &
    job new_pick_pkg_s$s $NEW --money=394 --seed=$s --gb-follow=pick $PKG &
  done
  for s in 1 2; do job new_pick_today_s$s $NEW --money=394 --seed=$s --gb-follow=pick & done
  wait ;;
mid)
  for s in 1 2 3 4; do
    job mid_today_s$s $COMMON --money=2000 --buy=$MID --seed=$s &
    job mid_pkg_s$s $COMMON --money=2000 --buy=$MID --seed=$s $PKG &
  done
  for s in 1 2; do job mid_pick_pkg_s$s $COMMON --money=2000 --buy=$MID --seed=$s --gb-follow=pick $PKG & done
  wait ;;
full)
  for s in 1 2 3 4; do
    job full_today_s$s $COMMON --money=20000 --buy=$FULL --signboard=1 --claims=25 --seed=$s &
    job full_pkg_s$s $COMMON --money=20000 --buy=$FULL --signboard=1 --claims=25 --seed=$s $PKG &
  done
  job fullg_today_s1 $COMMON --money=20000 --buy=$FULL,galla --signboard=1 --claims=25 --seed=1 &
  job fullg_pkg_s1 $COMMON --money=20000 --buy=$FULL,galla --signboard=1 --claims=25 --seed=1 $PKG &
  wait ;;
idle394)
  job new_idle394_today_s1 $NEW --money=394 --seed=1 &
  for s in 1 2; do job new_idle394_pkg_s$s $NEW --money=394 --seed=$s $PKG & done
  wait ;;
p0hard)
  job mid_pkghard_s1 $COMMON --money=2000 --buy=$MID --seed=1 --gb-k=1.15 --gb-p0hard=4 --gb-cueall &
  job full_pkghard_s1 $COMMON --money=20000 --buy=$FULL --signboard=1 --claims=25 --seed=1 --gb-k=1.15 --gb-p0hard=4 --gb-cueall &
  wait ;;
esac
echo BATCH $1 DONE
