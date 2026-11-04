"""GA prototype patch (throw-away). Applies the package's sim changes to a QA slot copy.
Usage: python3.13 -I -B patch_pkg.py SLOT_PROJ_DIR
Every change is behind a --ga-* flag; with no --ga-* flag the game runs as today.
  --ga-k=K            free-play ramp k (after the tutorial; the tutorial keeps ramp_capacity_k)     [GA-2, P1]
  --ga-rush=M         dinner rush: demand x M while Game.day_phase is in [from, to)                [GA-3, P4]
  --ga-rush-from=P --ga-rush-to=P   rush window in day phase (default 0.64-0.79 = 90 s of a 600 s day)
  --ga-cashline=N     bill line full at N a cash counter: done eaters wait at their seat to pay   [GA-1, P0]
  --ga-dampmin=D      free-play floor of the backlog damping (1.0 = no damping)                     [GA-2]
  --ga-cue-all        cue every drive-past at the gate (not only with seats full / a door line)     [GA-5, P10]
station_node.gd: cooks work Engine meta "ga_hold_<id>" times faster (the probe sets it)          [GA-8, A7 stand-in]
"""
import sys

proj = sys.argv[1]


def patch(path, pairs):
    p = f"{proj}/{path}"
    s = open(p, encoding="utf-8").read()
    for old, new in pairs:
        n = s.count(old)
        if n != 1:
            raise SystemExit(f"{path}: anchor found {n} times: {old[:80]!r}")
        s = s.replace(old, new, 1)
    open(p, "w", encoding="utf-8").write(s)
    print("patched", path)


SIM = "scripts/v3/world/sim.gd"
patch(SIM, [
    # flags
    ("var baraat_passed: int = 0\n",
     "var baraat_passed: int = 0\n"
     "## GA prototype (throw-away): see design_work/ga/patch_pkg.py.\n"
     "var ga_k: float = -1.0\n"
     "var ga_rush: float = 1.0\n"
     "var ga_rush_from: float = 0.64\n"
     "var ga_rush_to: float = 0.79\n"
     "var ga_cashline: int = -1\n"
     "var ga_dampmin: float = -1.0\n"
     "var ga_cue_all: bool = false\n"
     "var ga_rush_on: bool = false\n"),
    ("\t\t\tif a.begins_with(\"--tray=\"):\n",
     "\t\t\tif a.begins_with(\"--ga-k=\"):\n\t\t\t\tga_k = float(a.get_slice(\"=\", 1))\n"
     "\t\t\telif a.begins_with(\"--ga-rush=\"):\n\t\t\t\tga_rush = float(a.get_slice(\"=\", 1))\n"
     "\t\t\telif a.begins_with(\"--ga-rush-from=\"):\n\t\t\t\tga_rush_from = float(a.get_slice(\"=\", 1))\n"
     "\t\t\telif a.begins_with(\"--ga-rush-to=\"):\n\t\t\t\tga_rush_to = float(a.get_slice(\"=\", 1))\n"
     "\t\t\telif a.begins_with(\"--ga-cashline=\"):\n\t\t\t\tga_cashline = int(a.get_slice(\"=\", 1))\n"
     "\t\t\telif a.begins_with(\"--ga-dampmin=\"):\n\t\t\t\tga_dampmin = float(a.get_slice(\"=\", 1))\n"
     "\t\t\telif a == \"--ga-cue-all\":\n\t\t\t\tga_cue_all = true\n"
     "\t\t\tif a.begins_with(\"--tray=\"):\n"),
    # GA-1: the room gate counts the cashier line beyond N a counter
    ("\treturn seats_free() + _seats_freeing() + DOOR_LINE_PLACES - door_queue.size() - arrivals_incoming()\n",
     "\treturn seats_free() + _seats_freeing() + DOOR_LINE_PLACES - door_queue.size() - arrivals_incoming()\n\n\n"
     "## GA-1 (P0): the bill line is full: ga_cashline a cash counter, counting\n"
     "## travellers standing up to go and pay. Travellers who finish eating then wait\n"
     "## at their seat to pay (traveller.gd), so the seats - and the gate - fill.\n"
     "func ga_bill_full() -> bool:\n"
     "\tif ga_cashline < 0 or not Game.is_tutorial_done():\n\t\treturn false\n"
     "\tvar line: int = 0\n\tvar n: int = 0\n"
     "\tfor g in gallas:\n\t\tif is_instance_valid(g):\n\t\t\tn += 1\n\t\t\tline += int(g.call(\"queue_length\"))\n"
     "\tfor t in travellers:\n\t\tif is_instance_valid(t) and t.state == Traveller.S.STANDING:\n\t\t\tline += 1\n"
     "\treturn line >= ga_cashline * maxi(1, n)\n\n\n"
     "## GA-3 (P4): the dinner rush window (free play only).\n"
     "func _ga_in_rush() -> bool:\n"
     "\tif ga_rush <= 1.0 or not Game.is_tutorial_done():\n\t\treturn false\n"
     "\tvar ph: float = float(Game.day_phase)\n"
     "\treturn ph >= ga_rush_from and ph < ga_rush_to\n"),
    # GA-2 damping floor in free play
    ("\tvar damp_now: float = clampf(_bus_value(\"ramp_backlog_s\", RAMP_BACKLOG_S) / maxf(0.001, backlog_s),\n"
     "\t\t\t_bus_value(\"ramp_backlog_min\", RAMP_BACKLOG_MIN), 1.0)\n",
     "\tvar dmin: float = _bus_value(\"ramp_backlog_min\", RAMP_BACKLOG_MIN)\n"
     "\tif ga_dampmin >= 0.0 and Game.is_tutorial_done():\n\t\tdmin = ga_dampmin\n"
     "\tvar damp_now: float = clampf(_bus_value(\"ramp_backlog_s\", RAMP_BACKLOG_S) / maxf(0.001, backlog_s),\n"
     "\t\t\tminf(dmin, 1.0), 1.0)\n"),
    # GA-2 free-play k and GA-3 rush on the target
    ("\tvar target: float = clampf(_bus_value(\"ramp_capacity_k\", RAMP_K) * m, lo, hi) * _damp\n",
     "\tvar kk: float = _bus_value(\"ramp_capacity_k\", RAMP_K)\n"
     "\tif ga_k > 0.0 and Game.is_tutorial_done():\n\t\tkk = ga_k\n"
     "\tvar target: float = clampf(kk * m, lo, hi) * _damp\n"
     "\tvar rush_now: bool = _ga_in_rush()\n"
     "\tif rush_now:\n\t\ttarget *= ga_rush\n"
     "\tif rush_now != ga_rush_on:\n\t\tga_rush_on = rush_now\n"
     "\t\tprint(\"[ga] rush %s at sim %.1f phase %.3f\" % [\"start\" if rush_now else \"end\", sim_clock, float(Game.day_phase)])\n"),
    # GA-1: a traveller waiting at the seat to pay is not "about to free" it
    ("\t\tif t.state == Traveller.S.EATING or t.state == Traveller.S.STANDING:\n\t\t\tn += 1\n",
     "\t\tif (t.state == Traveller.S.EATING and not t.ga_wait_pay) or t.state == Traveller.S.STANDING:\n\t\t\tn += 1\n"),
    # GA-5 cue every drive-past
    ("\tif seats_free() > 0 and door == 0:\n\t\tif OS.is_debug_build():\n\t\t\tprint(\"[sim] drive-past cue dropped",
     "\tif seats_free() > 0 and door == 0 and not ga_cue_all:\n\t\tif OS.is_debug_build():\n\t\t\tprint(\"[sim] drive-past cue dropped"),
])

patch("scripts/v3/world/traveller.gd", [
    ("var _eat_left: float = 0.0\n",
     "var _eat_left: float = 0.0\n## GA-1 prototype: done eating, waiting at the seat for room in the bill line.\nvar ga_wait_pay: bool = false\n"),
    ("\t\tACT.EAT:\n\t\t\t_eat_left -= delta\n\t\t\tif _eat_left <= 0.0:\n\t\t\t\t_act = ACT.NONE\n\t\t\t\t_stand_up()\n",
     "\t\tACT.EAT:\n\t\t\t_eat_left -= delta\n\t\t\tif _eat_left <= 0.0:\n"
     "\t\t\t\tif _sim != null and _sim.ga_bill_full():\n\t\t\t\t\tga_wait_pay = true\n\t\t\t\t\t_eat_left = 0.25\n"
     "\t\t\t\telse:\n\t\t\t\t\tga_wait_pay = false\n\t\t\t\t\t_act = ACT.NONE\n\t\t\t\t\t_stand_up()\n"),
])

patch("scripts/v3/world/station_node.gd", [
    ("\t\telif s.phase == P.RUN:\n\t\t\ts.elapsed += delta\n",
     "\t\telif s.phase == P.RUN:\n\t\t\ts.elapsed += delta * float(Engine.get_meta(\"ga_hold_\" + id, 1.0))\n"),
])
