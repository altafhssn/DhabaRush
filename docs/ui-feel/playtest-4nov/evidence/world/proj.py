"""Ortho projection of the game camera (camera_rig.gd: rotation (-50, 45, 0), KEEP_HEIGHT 12 m over
1280 px at GAME/HOME 1.0; the rig target sits on the ground at the screen centre)."""
import math
PX_PER_M = 1280.0 / 12.0
C45 = math.cos(math.radians(45)); P = math.radians(50)
UPX, UPY, UPZ = -math.sin(P) * C45, math.cos(P), -math.sin(P) * C45   # camera up in world
def proj(x, y, z, cam=(2.6, 0.0, 4.0), zoom=1.0, W=720, H=1280):
    k = PX_PER_M / zoom
    dx, dz = x - cam[0], z - cam[2]
    sx = W / 2 + k * C45 * (dx - dz)
    sy = H / 2 - k * (UPX * dx + UPY * y + UPZ * dz)
    return (sx, sy)
def ground(sx, sy, cam=(2.6, 0.0, 4.0), zoom=1.0, W=720, H=1280):
    k = PX_PER_M / zoom
    a = (sx - W / 2) / (k * C45)              # dx - dz
    b = (sy - H / 2) / (k * math.sin(P) * C45)  # dx + dz
    dx, dz = (a + b) / 2, (b - a) / 2
    return (cam[0] + dx, cam[2] + dz)
if __name__ == "__main__":
    pts = {
      "chai_top": (1.70, 0.80, 1.75), "pinky": (0.70, 0.70, 1.75), "galla1_desk": (2.2, 0.85, 5.4),
      "table0_top today": (3.95, 0.5, 2.0), "table0_front_charpai today": (3.95, 0.42, 2.95),
      "table0_top W1": (11.0, 0.5, 2.0), "table0_front_charpai W1": (11.0, 0.42, 2.95),
      "table1_top": (6.9, 0.5, 6.1), "tandoor station today": (6.8, 0.85, 2.2), "tandoor station W1": (4.2, 0.85, 2.2),
      "tandoor cook W1 head": (4.2, 1.1, 1.3), "tandoor cook W1 feet": (4.2, 0.0, 1.3),
      "tandoor timer W1 (head+~0.35)": (4.2, 1.45, 1.3),
      "tandoor NEW tag tip W1 (y 2.35)": (4.2, 2.35, 2.2), "tandoor NEW tag tip today": (6.8, 2.35, 2.2),
      "kadai station today": (10.7, 0.85, 2.2), "kadai station W1": (7.3, 0.85, 2.2),
      "WALL_AD": (3.45, 1.9, 0.15), "TV": (0.14, 1.6, 2.7), "door": (3.8, 0.0, 9.0), "gate board": (5.5, 0.5, 9.1),
      "waiter tag (ghost waiter 2)": (3.1, 1.32, 4.5), "tray rack": (1.6, 0.6, 3.42),
      "chai_marker": (1.15, 1.05, 1.75), "galla_marker": (1.75, 1.05, 5.4),
      "slab W1 corners": None,
    }
    for k, v in pts.items():
        if v is None: continue
        print("%-36s (%6.1f, %6.1f)" % (k, *proj(*v)))
    for c in [(3.0, 0.4), (5.9, 0.4), (5.9, 3.4), (3.0, 3.4)]:
        print("slab W1 floor corner", c, "-> (%.0f, %.0f)" % proj(c[0], 0, c[1]))
    for name, (sx, sy) in {"TL": (0, 0), "TR": (720, 0), "BR": (720, 1280), "BL": (0, 1280),
                           "safe TL": (24, 300), "safe TR": (696, 300), "safe BR": (696, 1100), "safe BL": (24, 1100)}.items():
        print("home frustum %-8s ground (%.2f, %.2f)" % (name, *ground(sx, sy)))
    # hoarding view checks
    HV = (19.0, 0.0, 15.0); H = (21.9, 0.0, 18.0)
    for lv, (w, y0, y1) in {"L1": (1.6, 1.3, 2.1), "L2": (2.6, 2.0, 3.3), "L3": (3.4, 2.6, 4.3), "L4": (4.2, 3.1, 5.2)}.items():
        cs = [proj(H[0] + sx * w / 2, yy, H[2], cam=HV) for sx in (-1, 1) for yy in (y0, y1)]
        xs = [c[0] for c in cs]; ys = [c[1] for c in cs]
        print("hoarding %s board screen x %.0f..%.0f y %.0f..%.0f" % (lv, min(xs), max(xs), min(ys), max(ys)))
    print("hoarding origin at view", proj(*H, cam=HV), "kulhad top L5 (y 6.5)", proj(H[0], 6.5, H[2], cam=HV))
