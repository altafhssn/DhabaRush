# Port of scripts/v3/world/dish_art.gd (Dhaba Rush) to SVG, for a readability check only.
# Each drawer paints into a 96 x 108 cell; ellipses/rects follow the GDScript calls one for one,
# the row-by-row tumblers become trapezoids. Output: dishes.json {id: svg_inner}.
import json, math, sys
PI = math.pi
out = []
def hexc(c):
    r, g, b = [max(0, min(255, int(round(v * 255)))) for v in c[:3]]
    return "#%02X%02X%02X" % (r, g, b)
def darken(c, a): return tuple(v * (1 - a) for v in c[:3])
def lighten(c, a): return tuple(v + (1 - v) * a for v in c[:3])
def ell(cx, cy, rx, ry, col): out.append('<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s"/>' % (cx, cy, rx, ry, hexc(col)))
def rect(x, y, w, h, col): out.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="%s"/>' % (x, y, w, h, hexc(col)))
def poly(pts, col): out.append('<polygon points="%s" fill="%s"/>' % (" ".join("%.1f,%.1f" % p for p in pts), hexc(col)))
def line(x0, y0, x1, y1, w, col): out.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="%s" stroke-width="%.1f" stroke-linecap="round"/>' % (x0, y0, x1, y1, hexc(col), w))
def lerp(a, b, u): return a + (b - a) * u
STEAM = (0.62, 0.62, 0.66); STEEL = (0.74, 0.77, 0.8)
ROTI_SPOTS = [(38, 36), (57, 40), (44, 55), (60, 53), (35, 49), (51, 31)]

def tumbler(cx, top, bot, hw0, hw1, body, side, side_at=0.4, stripe=True, stripe_col=(0.95, 0.97, 0.98)):
    poly([(cx - hw0, top), (cx + hw0, top), (cx + hw1, bot + 1), (cx - hw1, bot + 1)], body)
    poly([(cx + hw0 * side_at, top), (cx + hw0, top), (cx + hw1, bot + 1), (cx + hw1 * side_at, bot + 1)], side)
    if stripe:
        poly([(cx - hw0 * 0.55, top), (cx - hw0 * 0.55 + 2, top), (cx - hw1 * 0.55 + 2, bot + 1), (cx - hw1 * 0.55, bot + 1)], stripe_col)

def steam(cx, base_y, n, rise, dx0, pitch, r=1.4):
    for k in range(n):
        bx = cx + dx0 + k * pitch
        for i in range(rise):
            ell(bx + math.sin(i * 0.7 + k) * 2.5, base_y - i, r, r, STEAM)

def stroke(x0, y0, x1, y1, r, col): line(x0, y0, x1, y1, 2 * r, col)
def katori_with(cx, edge, food):
    ell(cx, 50, 24, 15, (0.55, 0.57, 0.6)); ell(cx, 42, 24, 8, (0.75, 0.77, 0.8)); ell(cx, 42, 20, 6, edge); ell(cx - 1, 41.5, 17, 4.6, food)
def baati_ball(x, y, r):
    ell(x, y, r, r * 0.88, (0.5, 0.29, 0.12)); ell(x - 0.6, y - 0.8, r - 1.3, r * 0.88 - 1.5, (0.8, 0.53, 0.26))
    ell(x - r * 0.35, y - r * 0.42, r * 0.32, r * 0.2, (0.93, 0.72, 0.44))
    ghee = (1.0, 0.86, 0.38); rect(x - r * 0.55, y - r * 0.3, r * 1.1, 2, ghee); rect(x - 1, y - r * 0.78, 2, r * 0.95, ghee)

def kulhad_body(cx, top, bot, top_col):
    clay = (0.78, 0.4, 0.2); clay_dark = (0.58, 0.26, 0.12)
    tumbler(cx, top, bot, 19, 13, clay, darken(clay, 0.15), 0.45, False)
    poly([(cx - lerp(19, 13, (37 - top) / (bot - top)), 37), (cx + lerp(19, 13, (37 - top) / (bot - top)), 37), (cx + lerp(19, 13, (41 - top) / (bot - top)), 41), (cx - lerp(19, 13, (41 - top) / (bot - top)), 41)], clay_dark)
    ell(cx, bot, 13, 3.5, clay_dark); ell(cx, top, 19.5, 5.5, clay_dark); ell(cx, top, 16.5, 4.0, top_col)

def d_kulhad(cx):
    kulhad_body(cx, 28, 66, (0.72, 0.47, 0.25)); ell(cx - 3, 27.5, 6, 1.6, (0.95, 0.85, 0.66))
    for k in range(2):
        bx = cx - 6 + k * 11
        for i in range(12): ell(bx + math.sin(i * 0.7 + k) * 2.5, 21 - i, 1.4, 1.4, STEAM)
def d_roti(cx):
    ell(cx, 46, 25, 23, (0.6, 0.38, 0.18)); ell(cx, 45, 23, 21, (0.93, 0.74, 0.43))
    for sx, sy in ROTI_SPOTS: ell(sx + cx - 48, sy, 3, 2.4, (0.48, 0.28, 0.12))
    ell(cx + 1, 45, 5.5, 4.5, (1.0, 0.86, 0.3))
def lassi_glass(cx, body=STEEL, side=None, top_col=(0.98, 0.97, 0.93), stripe_col=(0.95, 0.97, 0.98)):
    side = side or darken(body, 0.18)
    tumbler(cx, 28, 69, 15, 11, body, side, 0.4, True, stripe_col)
    ell(cx, 69, 11, 3, darken(STEEL, 0.35)); ell(cx, 28, 15.5, 4.5, darken(STEEL, 0.3)); ell(cx, 28, 13.5, 3.6, top_col)
    ell(cx, 24.5, 10, 6, (1.0, 0.93, 0.74)); ell(cx - 3, 22, 4, 1.8, (1.0, 0.98, 0.9))
def d_lassi(cx):
    lassi_glass(cx); ell(cx + 2, 21.5, 2.2, 2.0, (0.95, 0.55, 0.12)); ell(cx - 4.5, 24, 1.6, 1.2, (0.45, 0.7, 0.25))
def d_bhurji(cx):
    ell(cx, 53, 28, 15, (0.55, 0.57, 0.6)); ell(cx, 51.5, 26, 13, (0.8, 0.82, 0.85)); ell(cx, 51.5, 20, 9, (0.88, 0.9, 0.92))
    ell(cx - 7, 48, 14, 8.5, (0.86, 0.62, 0.12)); ell(cx - 7.5, 46.5, 12.5, 7, (0.99, 0.8, 0.24)); ell(cx - 10, 44, 5, 2.2, (1.0, 0.92, 0.55))
    for fx, fy, fz in [(-12, 47, 0), (-4, 44, 1), (-1, 49, 0), (-9, 51, 1), (-15, 50, 1), (-6, 48.5, 0)]:
        ell(cx + fx, fy, 1.6, 1.3, (0.85, 0.2, 0.14) if fz < 0.5 else (0.25, 0.58, 0.18))
    for px, py in [(11, 46), (15, 54)]:
        ell(cx + px, py, 8.5, 6, (0.62, 0.36, 0.14)); ell(cx + px, py - 0.8, 7.5, 5, (0.88, 0.6, 0.28)); ell(cx + px - 1.5, py - 2.5, 4, 1.6, (1.0, 0.86, 0.45))
def d_dal(cx):
    katori_with(cx, (0.36, 0.15, 0.07), (0.47, 0.21, 0.1))
    ell(cx - 5, 41, 7, 1.7, (0.99, 0.95, 0.86)); ell(cx + 3, 43, 6, 1.5, (0.99, 0.95, 0.86)); ell(cx + 7, 39.5, 3.4, 2.6, (1.0, 0.86, 0.3)); ell(cx - 11, 43, 2.4, 1.4, (0.3, 0.6, 0.2))
    for k in range(2):
        bx = cx - 5 + k * 10
        for i in range(10): ell(bx + math.sin(i * 0.7 + k) * 2.2, 33 - i, 1.3, 1.3, STEAM)
def d_coffee(cx):
    ell(cx, 64, 24, 8, darken(STEEL, 0.35)); ell(cx, 62.5, 22.5, 6.5, STEEL); ell(cx, 62, 16, 4, darken(STEEL, 0.12))
    tumbler(cx, 30, 60, 13, 10, STEEL, darken(STEEL, 0.18), 0.4, True)
    ell(cx, 60, 10, 2.6, darken(STEEL, 0.35)); ell(cx, 30, 13.5, 4, darken(STEEL, 0.3)); ell(cx, 30, 11.5, 3.2, (0.42, 0.24, 0.12))
    ell(cx - 3, 29, 6.5, 1.8, (0.93, 0.86, 0.74)); ell(cx + 1, 29.5, 3.5, 1.2, (0.42, 0.24, 0.12)); steam(cx, 23, 2, 10, -5, 10, 1.3)
def d_green_tea(cx):
    glass = (0.86, 0.93, 0.8); tea = (0.72, 0.84, 0.45)
    ell(cx, 63, 25, 7.5, darken(STEEL, 0.35)); ell(cx, 61.5, 23.5, 6, STEEL)
    tumbler(cx, 36, 59, 15, 12, glass, darken(glass, 0.14), 0.45, True, (0.97, 1.0, 0.95))
    poly([(cx - 13 + 0.5, 40), (cx + 13 - 0.5, 40), (cx + 10.5, 58), (cx - 10.5, 58)], tea)
    for i in range(9):
        a = -PI * 0.5 + PI * i / 8; ell(cx + 15 + math.cos(a) * 5.5, 47 + math.sin(a) * 6.5, 1.8, 1.8, darken(glass, 0.2))
    ell(cx, 59, 12, 3, darken(glass, 0.3)); ell(cx, 36, 15.5, 4.4, darken(glass, 0.3)); ell(cx, 36, 13.5, 3.5, lighten(tea, 0.1))
    ell(cx - 4, 36, 4, 1.6, (0.3, 0.6, 0.2)); ell(cx + 11, 31, 5.5, 5.5, (1.0, 0.86, 0.3)); ell(cx + 11, 31, 3.6, 3.6, (1.0, 0.95, 0.6)); steam(cx, 29, 1, 7, -6, 0, 1.2)
def d_kesar_doodh(cx):
    kulhad_body(cx, 28, 66, (1.0, 0.85, 0.6)); ell(cx - 4, 27.2, 6, 1.6, (1.0, 0.93, 0.78))
    for fx, fy in [(-9, 28.5), (-2, 30), (5, 27.5), (10, 29.5)]: ell(cx + fx, fy, 1.6, 1.2, (0.35, 0.62, 0.22))
    for tx, ty in [(-5, 27), (2, 28.5), (8, 26.5)]: rect(cx + tx, ty, 3, 1, (0.95, 0.45, 0.1))
    steam(cx, 21, 1, 11, 2, 0, 1.4)
def d_naan(cx):
    for pass_ in range(2):
        for i in range(16):
            u = i / 15; cy = 26 + u * 38; rx = lerp(7, 24, math.sqrt(u))
            if pass_ == 0: ell(cx, cy, rx + 1.6, 4.5, (0.6, 0.38, 0.18))
            else: ell(cx, cy, rx, 3.6, (0.95, 0.8, 0.5))
    for sx, sy in [(-3, 36), (8, 46), (-11, 52), (4, 58), (13, 57)]: ell(cx + sx, sy, 3, 2.3, (0.52, 0.3, 0.12))
    ell(cx - 2, 47, 5, 3.8, (1.0, 0.86, 0.3))
def d_keema_paratha(cx):
    ell(cx, 46, 25, 23, (0.55, 0.33, 0.15)); ell(cx, 45.5, 23.5, 21.5, (0.72, 0.5, 0.26)); ell(cx, 45, 21, 19, (0.88, 0.66, 0.36))
    for sx, sy in [(-10, 38), (2, 34), (11, 41), (-6, 49), (6, 52), (-13, 55), (13, 54)]: ell(cx + sx, sy, 2.6, 2.2, (0.45, 0.25, 0.12))
    ell(cx + 3, 44, 6, 4.6, (0.93, 0.78, 0.84)); ell(cx + 3, 44, 3.8, 2.8, (0.88, 0.66, 0.36)); ell(cx - 4, 42, 2.4, 1.5, (0.3, 0.6, 0.2))
def d_kulcha(cx):
    ell(cx, 46, 25, 23, (0.6, 0.38, 0.18)); ell(cx, 45, 23, 21, (0.96, 0.84, 0.58)); ln = (0.7, 0.5, 0.26)
    for k in range(2): rect(cx - 16, 38 + k * 14, 32, 2, ln)
    for k in range(2): rect(cx - 7 + k * 14, 28, 2, 35, ln)
    ell(cx - 2, 44, 5.5, 4, (1.0, 0.86, 0.3)); ell(cx + 12, 52, 5, 1.8, (0.85, 0.15, 0.1)); ell(cx + 16.5, 51, 1.4, 1.2, (0.3, 0.55, 0.2))
def d_chaas(cx):
    tumbler(cx, 28, 69, 13, 10, STEEL, darken(STEEL, 0.18), 0.4, True)
    ell(cx, 69, 10, 2.8, darken(STEEL, 0.35)); ell(cx, 28, 13.5, 4, darken(STEEL, 0.3)); ell(cx, 28, 11.5, 3.2, (0.97, 0.97, 0.94))
    for fx, fy in [(-7, 28), (-2, 29.5), (3, 27), (7, 29), (0, 26.5)]: rect(cx + fx, fy, 2, 1, (0.35, 0.22, 0.1))
    ell(cx - 5, 24.5, 4, 2, (0.3, 0.62, 0.22)); ell(cx + 1, 23, 3.6, 1.8, (0.38, 0.7, 0.26))
def d_mango_lassi(cx):
    body = (1.0, 0.7, 0.2)
    tumbler(cx, 28, 69, 15, 11, body, darken(body, 0.18), 0.4, True, (1.0, 0.88, 0.6))
    ell(cx, 69, 11, 3, darken(STEEL, 0.35)); ell(cx, 28, 15.5, 4.5, darken(STEEL, 0.3)); ell(cx, 28, 13.5, 3.6, (1.0, 0.8, 0.4))
    ell(cx, 24.5, 10, 6, (1.0, 0.93, 0.74)); ell(cx - 3, 22, 4, 1.8, (1.0, 0.98, 0.9))
    ell(cx + 13, 26, 6.5, 4, (0.85, 0.45, 0.08)); ell(cx + 13, 25.5, 5, 2.8, (1.0, 0.6, 0.1))
def d_patiala(cx):
    tumbler(cx, 22, 72, 17, 13, STEEL, darken(STEEL, 0.18), 0.4, True)
    for y in range(28, 68, 11):
        u = (y - 22) / 50; hw = lerp(17, 13, u); rect(cx - hw, y, 2 * hw, 1, darken(STEEL, 0.28))
    ell(cx, 72, 13, 3.4, darken(STEEL, 0.35)); ell(cx, 22, 17.5, 5, darken(STEEL, 0.3)); ell(cx, 22, 15.5, 4, (0.98, 0.97, 0.93))
    ell(cx, 17.5, 13.5, 8, (1.0, 0.93, 0.74)); ell(cx - 4, 14, 5, 2.2, (1.0, 0.98, 0.9)); ell(cx + 3, 13, 2.4, 2.2, (0.95, 0.55, 0.12))
def d_paneer(cx):
    iron = (0.3, 0.3, 0.33)
    ell(cx, 50, 24, 15, iron); ell(cx, 42, 24, 8, lighten(iron, 0.18)); ell(cx - 25, 43, 4, 3, lighten(iron, 0.1)); ell(cx + 25, 43, 4, 3, lighten(iron, 0.1))
    ell(cx, 42, 20, 6, (0.72, 0.3, 0.08)); ell(cx - 1, 41.5, 17, 4.6, (0.9, 0.42, 0.12))
    for px, py in [(-9, 41), (-1, 39.5), (7, 42), (2, 44)]: rect(cx + px - 2, py - 2, 5, 4, (0.97, 0.96, 0.9))
    for gx, gy in [(-5, 43.5), (11, 40), (-13, 43)]: ell(cx + gx, gy, 2.4, 1.5, (0.3, 0.62, 0.2))
    steam(cx, 33, 1, 9, 4, 0, 1.3)
def d_chole(cx):
    katori_with(cx, (0.38, 0.22, 0.1), (0.5, 0.3, 0.15))
    for px, py in [(-12, 41), (-7, 43.5), (-3, 40), (2, 43), (6, 40.5), (10, 43), (-9, 39), (12, 40.5)]: ell(cx + px, py, 1.9, 1.5, (0.72, 0.5, 0.26))
    ell(cx + 4, 41, 5.5, 3.2, (0.93, 0.78, 0.84)); ell(cx + 4, 41, 3.4, 1.9, (0.5, 0.3, 0.15)); ell(cx - 14, 38, 4, 2.4, (0.6, 0.8, 0.3)); ell(cx - 14, 37.5, 2.4, 1.3, (0.85, 0.95, 0.6))
def d_chai_glass(cx, gur):
    chai = (0.46, 0.25, 0.11) if gur else (0.68, 0.42, 0.21); glass = (0.86, 0.93, 0.97); top, bot = 31, 63
    ell(cx, 66, 21.5, 6.2, darken(STEEL, 0.35)); ell(cx, 64.8, 20, 5, STEEL); ell(cx, 64.6, 12.5, 2.8, darken(STEEL, 0.12))
    tumbler(cx, top + 4, bot - 3, 16, 11.5, chai, darken(chai, 0.18), 0.4, False)
    for k in range(5):
        f = -0.72 + 0.36 * k
        poly([(cx + 16 * f, top + 5), (cx + 16 * f + 1, top + 5), (cx + 11.5 * f + 1, bot - 3), (cx + 11.5 * f, bot - 3)], darken(chai, 0.32))
    tumbler(cx, bot - 3, bot, 11.5, 11, glass, darken(glass, 0.15), 0.4, False); ell(cx, bot, 11, 2.8, darken(glass, 0.3))
    tumbler(cx, top, top + 4, 16.8, 16, glass, darken(glass, 0.12), 0.45, False)
    ell(cx, top, 17.2, 4.6, darken(glass, 0.3)); ell(cx, top + 1.2, 15, 3.4, lighten(chai, 0.18)); ell(cx - 2, top + 0.8, 8, 1.6, (0.95, 0.86, 0.72))
    poly([(cx - 16.6 * 0.62, top + 2), (cx - 16.6 * 0.62 + 2, top + 2), (cx - 11.2 * 0.62 + 2, bot - 1), (cx - 11.2 * 0.62, bot - 1)], (0.97, 0.98, 1.0))
    if gur: ell(cx + 16, 63, 5, 3.4, (0.42, 0.24, 0.08)); ell(cx + 15.5, 62, 4.2, 2.6, (0.7, 0.44, 0.14)); ell(cx + 14.5, 61.2, 1.8, 1.0, (0.9, 0.66, 0.3))
    steam(cx, 23, 2, 10, -5, 10, 1.3)
def d_shikanji(cx):
    glass = (0.86, 0.93, 0.97); drink = (0.84, 0.92, 0.48); top, bot = 24, 69
    ell(cx, 71.5, 19, 5, darken(STEEL, 0.35)); ell(cx, 70.5, 17.5, 4, STEEL)
    tumbler(cx, top + 1, bot - 5, 14, 11.5, drink, darken(drink, 0.16), 0.4, True, (1.0, 1.0, 0.88))
    tumbler(cx, bot - 5, bot, 11.5, 11, glass, darken(glass, 0.15), 0.4, False); ell(cx, bot, 11, 2.8, darken(glass, 0.3))
    ell(cx, top, 14.6, 4.2, darken(glass, 0.3)); ell(cx, top + 0.6, 12.8, 3.2, (0.97, 0.97, 0.7))
    rect(cx - 9, top - 2, 5, 4, (0.97, 0.99, 1.0)); rect(cx - 1, top - 1, 5, 3, (0.9, 0.96, 1.0))
    ell(cx + 12, top - 2.5, 6.6, 6.6, (0.93, 0.76, 0.12)); ell(cx + 12, top - 2.5, 4.8, 4.8, (1.0, 0.95, 0.58)); ell(cx + 12, top - 2.5, 1.2, 1.2, (0.95, 0.85, 0.4))
    ell(cx - 6, top - 5, 4.6, 2, (0.24, 0.58, 0.2)); ell(cx - 1.5, top - 6.5, 3.6, 1.8, (0.33, 0.7, 0.28))
def d_missi_roti(cx):
    ell(cx, 46, 25, 23, (0.64, 0.38, 0.1)); ell(cx, 45, 23, 21, (0.97, 0.7, 0.26))
    for sx, sy in ROTI_SPOTS: ell(sx + cx - 48, sy, 2.6, 2.1, (0.62, 0.32, 0.1))
    for gx, gy in [(-12, 42), (4, 36), (13, 47), (-5, 56), (8, 58), (-15, 52)]: ell(cx + gx, gy, 1.8, 1.2, (0.28, 0.56, 0.18))
    ell(cx + 1, 45.5, 7.5, 5.8, (0.8, 0.8, 0.78)); ell(cx + 0.5, 44.5, 6.6, 4.8, (0.99, 0.99, 0.97)); ell(cx - 1.5, 43, 2.6, 1.4, (1, 1, 1))
def d_lahsun_roti(cx):
    ell(cx - 3, 44, 24, 22, (0.42, 0.24, 0.1)); ell(cx - 3, 43, 22, 20, (0.9, 0.7, 0.4))
    for sx, sy in [(-14, 36), (6, 33), (-4, 44), (9, 46), (-16, 50), (-6, 56), (12, 37), (-10, 28)]: ell(cx + sx, sy, 2.8, 2.2, (0.36, 0.2, 0.08))
    ell(cx + 15, 61, 11, 7, (0.55, 0.57, 0.6)); ell(cx + 15, 58.5, 10.5, 4.6, (0.75, 0.77, 0.8)); ell(cx + 15, 58.5, 8.5, 3.4, (0.82, 0.14, 0.08))
    ell(cx + 12.5, 57.8, 2.6, 1.0, (1.0, 0.48, 0.32)); ell(cx + 18, 58.8, 1.4, 1.0, (0.98, 0.95, 0.88)); ell(cx + 15, 59.6, 1.2, 0.9, (0.98, 0.95, 0.88))
def d_baati(cx):
    ell(cx, 55, 28, 13, (0.55, 0.57, 0.6)); ell(cx, 53.5, 26, 11, (0.8, 0.82, 0.85)); baati_ball(cx - 11, 44, 11); baati_ball(cx + 11, 44, 11); baati_ball(cx, 54, 11.5)
def d_rabri(cx):
    clay = (0.74, 0.38, 0.2)
    ell(cx, 51, 23, 15, darken(clay, 0.15)); ell(cx - 7, 54, 5, 8, lighten(clay, 0.12)); ell(cx, 42, 24, 8.5, darken(clay, 0.35)); ell(cx, 42, 21.5, 6.6, (0.97, 0.9, 0.74)); ell(cx, 40.5, 16, 5, (1.0, 0.96, 0.86))
    for fx, fy, fz in [(-9, 41, 5), (5, 43, 6), (-2, 38.5, 4), (10, 39.5, 4)]: ell(cx + fx, fy, fz, 1.1, (0.9, 0.78, 0.56))
    for px, py in [(-4, 40), (7, 41), (-11, 43)]: ell(cx + px, py, 1.7, 1.1, (0.35, 0.62, 0.22))
    for tx, ty in [(-1, 42), (3, 38)]: rect(cx + tx, ty, 4, 1, (0.95, 0.45, 0.1))
def d_dal_baati(cx):
    ell(cx, 53, 30, 16, (0.55, 0.57, 0.6)); ell(cx, 51.5, 28, 14, (0.8, 0.82, 0.85))
    ell(cx - 10, 44, 12.5, 7.5, (0.55, 0.57, 0.6)); ell(cx - 10, 41.5, 12, 5.5, (0.75, 0.77, 0.8)); ell(cx - 10, 41.5, 10, 4.2, (0.96, 0.74, 0.2))
    for tx, ty, tz in [(-14, 41, 0), (-8, 42.5, 0), (-6, 40, 1), (-12, 43, 1)]: ell(cx + tx, ty, 1.5, 1.1, (0.85, 0.2, 0.1) if tz < 0.5 else (0.3, 0.6, 0.2))
    ell(cx - 6, 58, 11, 6, (0.72, 0.48, 0.12)); ell(cx - 6.5, 57, 9.5, 4.8, (0.9, 0.66, 0.2))
    for gx, gy in [(-10, 56), (-4, 55), (-7, 58.5), (-1, 57.5)]: ell(cx + gx, gy, 1.2, 1.0, (1.0, 0.84, 0.42))
    baati_ball(cx + 12, 43, 8.5); baati_ball(cx + 13, 55, 9)
def d_gatte(cx):
    katori_with(cx, (0.82, 0.38, 0.08), (0.98, 0.56, 0.16))
    for px, py in [(-11, 41.5), (-3, 43.5), (6, 40.5), (12, 42.5), (-6, 39)]: ell(cx + px, py, 3.8, 2.7, (0.8, 0.56, 0.12)); ell(cx + px - 0.3, py - 0.4, 2.7, 1.8, (1.0, 0.86, 0.36))
    for gx, gy in [(1, 41), (9, 44), (-14, 43.5)]: ell(cx + gx, gy, 2.2, 1.3, (0.3, 0.6, 0.2))
    steam(cx, 33, 1, 9, -4, 0, 1.3)
def d_ker_sangri(cx):
    katori_with(cx, (0.4, 0.26, 0.1), (0.55, 0.38, 0.16)); ell(cx, 39.5, 15, 5.5, (0.5, 0.35, 0.14)); olive = (0.45, 0.5, 0.18); brown = (0.36, 0.26, 0.1)
    stroke(cx - 14, 42, cx - 2, 37, 1.1, olive); stroke(cx - 6, 44, cx + 9, 39, 1.1, brown); stroke(cx + 2, 36.5, cx + 14, 41.5, 1.1, olive); stroke(cx - 11, 38, cx + 1, 43.5, 1.1, brown); stroke(cx + 6, 44, cx + 15, 43, 1.1, olive)
    for kx, ky in [(-8, 40), (4, 41.5), (10, 38.5), (-2, 39), (-13, 44)]: ell(cx + kx, ky, 1.9, 1.7, (0.26, 0.16, 0.07))
    stroke(cx - 3, 35.5, cx + 6, 34, 1.4, (0.8, 0.12, 0.08))
def d_laal_maas(cx):
    katori_with(cx, (0.45, 0.05, 0.04), (0.76, 0.1, 0.07)); ell(cx - 7, 40, 6, 1.3, (0.95, 0.36, 0.16))
    for mx, my in [(-10, 42), (-1, 43.5), (8, 41), (-4, 39)]: ell(cx + mx, my, 3.8, 2.6, (0.4, 0.2, 0.09)); ell(cx + mx - 0.6, my - 0.6, 2.4, 1.5, (0.58, 0.3, 0.14))
    stroke(cx + 9, 40.5, cx + 15, 37.5, 1.2, (0.95, 0.92, 0.84)); ell(cx + 15.5, 37.2, 2.2, 1.8, (0.98, 0.96, 0.9)); ell(cx + 3, 40.5, 2.2, 1.3, (0.3, 0.6, 0.2)); ell(cx - 13, 43.5, 2.0, 1.2, (0.3, 0.6, 0.2))
    steam(cx, 33, 1, 9, 3, 0, 1.3)

DRAW = {
    "chai.chai": lambda: d_chai_glass(48, False), "chai.coffee": lambda: d_coffee(48), "chai.green_tea": lambda: d_green_tea(48), "chai.kesar_doodh": lambda: d_kesar_doodh(48),
    "tandoor.roti": lambda: d_roti(48), "tandoor.naan": lambda: d_naan(48), "tandoor.keema_paratha": lambda: d_keema_paratha(48), "tandoor.kulcha": lambda: d_kulcha(48),
    "lassi.lassi": lambda: d_lassi(48), "lassi.chaas": lambda: d_chaas(48), "lassi.mango_lassi": lambda: d_mango_lassi(48), "lassi.patiala": lambda: d_patiala(48),
    "kadai.bhurji": lambda: d_bhurji(48), "kadai.dal": lambda: d_dal(48), "kadai.paneer": lambda: d_paneer(48), "kadai.chole": lambda: d_chole(48),
    "chai.masala_chai": lambda: d_kulhad(48), "chai.gur_chai": lambda: d_chai_glass(48, True), "chai.shikanji": lambda: d_shikanji(48), "chai.thandai": lambda: d_kesar_doodh(48),
    "tandoor.missi_roti": lambda: d_missi_roti(48), "tandoor.tandoori_roti": lambda: d_lahsun_roti(48), "tandoor.baati": lambda: d_baati(48), "tandoor.laccha_paratha": lambda: d_keema_paratha(48),
    "lassi.makhaniya": lambda: d_lassi(48), "lassi.chaach": lambda: d_chaas(48), "lassi.kesar_lassi": lambda: d_mango_lassi(48), "lassi.rabri": lambda: d_rabri(48),
    "kadai.dal_baati": lambda: d_dal_baati(48), "kadai.gatte": lambda: d_gatte(48), "kadai.ker_sangri": lambda: d_ker_sangri(48), "kadai.laal_maas": lambda: d_laal_maas(48),
}
res = {}
for k, fn in DRAW.items():
    out.clear(); fn(); res[k] = "".join(out)
json.dump(res, open(sys.argv[1], "w"))
print("drew", len(res), "dishes;", sum(len(v) for v in res.values()), "chars of svg")
