#!/usr/bin/env python3
"""Pacing simulator for Dhaba Rush.

Mirrors the game rules in scripts/autoload/game.gd + scripts/world/*.gd at the
"queue and timer" level (no walking paths) and plays with a greedy bot.
Reads data/economy.json so tuning changes are checked before they hit the game.

Usage: python3 tools/sim/pacing.py [--hours 3] [--seed 1] [--bot greedy|lazy]
"""
import argparse
import json
import math
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DT = 0.1


def fmt_time(s):
    return f"{int(s // 60):3d}:{int(s % 60):02d}"


def fmt_inr(v):
    if v >= 1e7:
        return f"{v / 1e7:.2f} Cr"
    if v >= 1e5:
        return f"{v / 1e5:.2f} L"
    return f"{v:,.0f}"


class Sim:
    def __init__(self, eco, seed, bot):
        self.e = eco
        self.rng = random.Random(seed)
        self.bot = bot
        self.t = 0.0
        self.money = float(eco["start_money"])
        self.earned = 0.0
        self.pads = set()
        self.pad_idx = 0
        self.levels = {"chai": 1, "tandoor": 0, "dal": 0, "bhaiya": 0, "signboard": 0}
        self.vehicles = []  # dicts: remaining customers
        self.customers = []
        self.queues = {k: [] for k in eco["stations"]}
        self.cooking = {k: None for k in eco["stations"]}
        self.spawn_timer = 1.0
        self.log = []
        self.lost_parking = 0
        self.lost_patience = 0
        self.served = 0
        self.income_window = []

    # ---- derived stats (keep in sync with game.gd) ----
    def has(self, pad):
        return pad in self.pads

    def seats(self):
        return self.e["start_seats"] + sum(p.get("seats", 0) for p in self.e["pads"] if p["id"] in self.pads)

    def parking(self):
        return self.e["start_parking"] + sum(p.get("parking", 0) for p in self.e["pads"] if p["id"] in self.pads)

    def is_night(self):
        tr = self.e["traffic"]
        cyc = tr["day_seconds"] + tr["night_seconds"]
        return (self.t % cyc) >= tr["day_seconds"]

    def spawn_interval(self):
        tr = self.e["traffic"]
        iv = tr["base_interval"] / (1 + tr["signboard_bonus_per_level"] * self.levels["signboard"])
        if self.is_night() and self.has("lights"):
            iv /= tr["night_mult"]
        return iv

    def cook_time(self, st):
        base = self.e["stations"][st]["cook_time"]
        return base / (1 + self.e["upgrades"]["bhaiya"]["speed_per_level"] * self.levels["bhaiya"])

    def price(self, st):
        lvl = self.levels[st]
        sl = self.e["station_level"]
        mult = 1 + sl["price_per_level"] * (lvl - 1)
        mult *= 2 ** sum(1 for d in sl["double_at"] if lvl >= d)
        return self.e["stations"][st]["price"] * mult

    def patience(self):
        c = self.e["customer"]
        return c["base_patience"] + (c["pump_patience_bonus"] if self.has("pump") else 0)

    def unlocked_stations(self):
        return [k for k, v in self.e["stations"].items() if self.levels[k] > 0]

    def level_cost(self, key):
        if key in self.e["stations"]:
            d = self.e["stations"][key]
        else:
            d = self.e["upgrades"][key]
        return d["cost_base"] * d["cost_growth"] ** self.levels[key]

    def level_max(self, key):
        d = self.e["stations"].get(key) or self.e["upgrades"][key]
        return d["max_level"]

    # ---- simulation ----
    def spawn_vehicle(self):
        choices = []
        for name, v in self.e["vehicles"].items():
            req = v.get("requires")
            if req and not self.has(req):
                continue
            choices.append((name, v))
        name, v = self.rng.choices(choices, weights=[c[1]["weight"] for c in choices])[0]
        if len(self.vehicles) >= self.parking():
            self.lost_parking += 1
            return
        n = self.rng.randint(*v["customers"])
        veh = {"left": n}
        self.vehicles.append(veh)
        c = self.e["customer"]
        for _ in range(n):
            self.customers.append({"veh": veh, "state": "walk", "timer": c["walk_time"],
                                   "spend": v["spend"], "station": None})

    def seated_count(self):
        return sum(1 for c in self.customers if c["state"] in ("seated", "eating"))

    def remove(self, cust):
        self.customers.remove(cust)
        cust["veh"]["left"] -= 1
        if cust["veh"]["left"] <= 0:
            self.vehicles.remove(cust["veh"])

    def step(self):
        self.t += DT
        self.spawn_timer -= DT
        if self.spawn_timer <= 0:
            self.spawn_timer = self.spawn_interval()
            self.spawn_vehicle()
        c = self.e["customer"]
        for cust in list(self.customers):
            cust["timer"] -= DT
            st = cust["state"]
            if st == "walk" and cust["timer"] <= 0:
                cust["state"] = "seat_wait"
                cust["timer"] = c["seat_wait"]
            if cust["state"] == "seat_wait":
                if self.seated_count() < self.seats():
                    cust["state"] = "seated"
                    cust["timer"] = self.patience()
                    cust["station"] = self.rng.choice(self.unlocked_stations())
                    self.queues[cust["station"]].append(cust)
                elif cust["timer"] <= 0:
                    self.lost_patience += 1
                    self.remove(cust)
            elif st == "seated" and cust["timer"] <= 0:
                q = self.queues[cust["station"]]
                if cust in q:
                    q.remove(cust)
                if self.cooking[cust["station"]] and self.cooking[cust["station"]][0] is cust:
                    self.cooking[cust["station"]] = None
                self.lost_patience += 1
                self.remove(cust)
            elif st == "eating" and cust["timer"] <= 0:
                self.remove(cust)
        for stn in self.queues:
            cur = self.cooking[stn]
            if cur is None and self.queues[stn]:
                cust = self.queues[stn].pop(0)
                self.cooking[stn] = [cust, self.cook_time(stn)]
                cur = self.cooking[stn]
            if cur:
                cur[1] -= DT
                if cur[1] <= 0:
                    cust = cur[0]
                    ratio = max(0.0, cust["timer"] / self.patience())
                    pay = self.price(stn) * cust["spend"] * (1 + c["tip_max"] * ratio)
                    self.money += pay
                    self.earned += pay
                    self.income_window.append((self.t, pay))
                    self.served += 1
                    cust["state"] = "eating"
                    cust["timer"] = c["eat_time"]
                    self.cooking[stn] = None

    def buy_pad(self, pad):
        self.money -= pad["cost"]
        self.pads.add(pad["id"])
        self.pad_idx += 1
        if pad["id"] in ("tandoor", "dal"):
            self.levels[pad["id"]] = 1
        if pad["id"] == "signboard":
            self.levels["signboard"] = 1
        self.log.append((self.t, pad["id"], pad["cost"], self.income_per_min()))

    def income_per_min(self):
        cutoff = self.t - 60
        self.income_window = [x for x in self.income_window if x[0] >= cutoff]
        return sum(p for _, p in self.income_window)

    def player(self):
        pads = self.e["pads"]
        nxt = pads[self.pad_idx] if self.pad_idx < len(pads) else None
        if nxt and self.money >= nxt["cost"]:
            self.buy_pad(nxt)
            return
        opts = []
        for key in list(self.e["stations"]) + list(self.e["upgrades"]):
            if self.levels[key] <= 0 or self.levels[key] >= self.level_max(key):
                continue
            opts.append((self.level_cost(key), key))
        if not opts:
            return
        cost, key = min(opts)
        share = 0.35 if self.bot == "greedy" else 0.15
        budget = self.money if not nxt else min(self.money, share * nxt["cost"] + max(0, self.money - nxt["cost"]))
        if cost <= budget:
            self.money -= cost
            self.levels[key] += 1

    def run(self, seconds, think_every=1.0):
        acc = 0.0
        while self.t < seconds:
            self.step()
            acc += DT
            if acc >= think_every:
                acc = 0
                self.player()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--hours", type=float, default=3.0)
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--bot", default="greedy", choices=["greedy", "lazy"])
    args = ap.parse_args()
    eco = json.loads((ROOT / "data/economy.json").read_text())
    sim = Sim(eco, args.seed, args.bot)
    sim.run(args.hours * 3600)
    print(f"{'time':>7}  {'unlock':<10} {'cost':>12}  income/min")
    for t, pid, cost, ipm in sim.log:
        print(f"{fmt_time(t)}  {pid:<10} {fmt_inr(cost):>12}  {fmt_inr(ipm)}")
    print("---")
    print("levels:", sim.levels)
    print(f"served {sim.served}, lost(no parking) {sim.lost_parking}, lost(patience/seat) {sim.lost_patience}")
    print(f"earned {fmt_inr(sim.earned)}, income/min at end {fmt_inr(sim.income_per_min())}")


if __name__ == "__main__":
    main()
