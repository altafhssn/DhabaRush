"""Plain PNG reader (zlib) + colour measures. No PIL.
  probe <png> x,y [x,y ...]         : 5x5 mean colour at points, plus WCAG contrast of every pair
  hue   <png>                        : hue-band shares (S>0.25,V>0.2 rule) and blue share
  floor <png> rx,ry,gx,gy,...        : floor-tile share by nearest-sample dE<12 to given sample points
"""
import sys, zlib, struct
import numpy as np


def read_png(path):
    d = open(path, "rb").read()
    assert d[:8] == b"\x89PNG\r\n\x1a\n"
    off = 8
    idat = b""
    w = h = bd = ct = 0
    while off < len(d):
        ln, = struct.unpack_from(">I", d, off)
        typ = d[off + 4:off + 8]
        body = d[off + 8:off + 8 + ln]
        off += 12 + ln
        if typ == b"IHDR":
            w, h, bd, ct, _, _, il = struct.unpack(">IIBBBBB", body)
            assert bd == 8 and il == 0, (bd, il)
        elif typ == b"IDAT":
            idat += body
        elif typ == b"IEND":
            break
    raw = zlib.decompress(idat)
    ch = {2: 3, 6: 4, 0: 1, 4: 2}[ct]
    stride = w * ch
    out = np.zeros((h, stride), dtype=np.uint8)
    prev = np.zeros(stride, dtype=np.int32)
    p = 0
    for y in range(h):
        f = raw[p]; p += 1
        line = np.frombuffer(raw, dtype=np.uint8, count=stride, offset=p).astype(np.int32); p += stride
        if f == 0:
            cur = line
        elif f == 1:
            cur = line.copy()
            for i in range(ch, stride):
                cur[i] = (cur[i] + cur[i - ch]) & 255
        elif f == 2:
            cur = (line + prev) & 255
        elif f == 3:
            cur = line.copy()
            for i in range(stride):
                a = cur[i - ch] if i >= ch else 0
                cur[i] = (cur[i] + ((a + prev[i]) >> 1)) & 255
        elif f == 4:
            cur = line.copy()
            for i in range(stride):
                a = cur[i - ch] if i >= ch else 0
                b = prev[i]
                c = prev[i - ch] if i >= ch else 0
                pp = a + b - c
                pa, pb, pc = abs(pp - a), abs(pp - b), abs(pp - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                cur[i] = (cur[i] + pr) & 255
        out[y] = cur
        prev = cur
    img = out.reshape(h, w, ch)[:, :, :3].astype(np.float64)
    return img


def lum(rgb):
    c = np.asarray(rgb, dtype=np.float64) / 255.0
    c = np.where(c <= 0.03928, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    return 0.2126 * c[..., 0] + 0.7152 * c[..., 1] + 0.0722 * c[..., 2]


def contrast(a, b):
    la, lb = lum(a), lum(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)


def to_lab(rgb):
    c = np.asarray(rgb, dtype=np.float64) / 255.0
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    M = np.array([[0.4124, 0.3576, 0.1805], [0.2126, 0.7152, 0.0722], [0.0193, 0.1192, 0.9505]])
    xyz = c @ M.T
    xyz = xyz / np.array([0.95047, 1.0, 1.08883])
    f = np.where(xyz > 0.008856, np.cbrt(xyz), 7.787 * xyz + 16 / 116)
    L = 116 * f[..., 1] - 16
    a = 500 * (f[..., 0] - f[..., 1])
    b = 200 * (f[..., 1] - f[..., 2])
    return np.stack([L, a, b], axis=-1)


def hsv(img):
    c = img / 255.0
    mx = c.max(axis=-1); mn = c.min(axis=-1)
    d = mx - mn
    h = np.zeros_like(mx)
    r, g, b = c[..., 0], c[..., 1], c[..., 2]
    m = d > 1e-9
    rm = m & (mx == r); gm = m & (mx == g) & ~rm; bm = m & ~rm & ~gm
    h[rm] = (60 * ((g - b)[rm] / d[rm])) % 360
    h[gm] = 60 * ((b - r)[gm] / d[gm]) + 120
    h[bm] = 60 * ((r - g)[bm] / d[bm]) + 240
    s = np.where(mx > 0, d / np.maximum(mx, 1e-9), 0)
    return h, s, mx


def hexs(c):
    return "#%02X%02X%02X" % tuple(int(round(v)) for v in c)


if __name__ == "__main__":
    cmd = sys.argv[1]
    img = read_png(sys.argv[2])
    H, W, _ = img.shape
    print("size", W, H)
    if cmd == "probe":
        pts = [tuple(int(v) for v in a.split(",")) for a in sys.argv[3:]]
        cols = []
        for (x, y) in pts:
            patch = img[y - 2:y + 3, x - 2:x + 3].reshape(-1, 3).mean(axis=0)
            cols.append(patch)
            lab = to_lab(patch)
            print("(%d,%d) %s L*=%.1f" % (x, y, hexs(patch), lab[0]))
        for i in range(len(pts)):
            for j in range(i + 1, len(pts)):
                dE = float(np.linalg.norm(to_lab(cols[i]) - to_lab(cols[j])))
                print("  %s vs %s : contrast %.2f dE %.1f" % (pts[i], pts[j], contrast(cols[i], cols[j]), dE))
    elif cmd == "hue":
        h, s, v = hsv(img)
        sat = (s > 0.25) & (v > 0.2)
        n = H * W
        bands = {"red 0-20": (0, 20), "orange 20-50": (20, 50), "yellow 50-70": (50, 70), "green 70-160": (70, 160),
                 "teal 160-200": (160, 200), "blue 200-260": (200, 260), "violet 260-330": (260, 330), "red2 330-360": (330, 360)}
        for k, (a, b) in bands.items():
            m = sat & (h >= a) & (h < b)
            print("%-16s %5.1f %%" % (k, 100 * m.sum() / n))
        print("neutral (not sat) %5.1f %%" % (100 * (~sat).sum() / n))
        print("mean S %.2f mean V %.2f" % (s.mean(), v.mean()))
        print("V<0.3 share %.1f %%" % (100 * (v < 0.3).sum() / n))
    elif cmd == "floor":
        vals = [int(v) for v in sys.argv[3].split(",")]
        pts = list(zip(vals[0::2], vals[1::2]))
        samples = [img[y - 2:y + 3, x - 2:x + 3].reshape(-1, 3).mean(axis=0) for (x, y) in pts]
        lab = to_lab(img)
        best = np.full((H, W), 1e9)
        for s_ in samples:
            d = np.linalg.norm(lab - to_lab(s_), axis=-1)
            best = np.minimum(best, d)
        m = best < 12
        print("floor-class share whole frame %.1f %%" % (100 * m.mean()))
        print("centre column x180-540 %.1f %%" % (100 * m[:, 180:540].mean()))
        print("lower middle x180-540 y640-1000 %.1f %%" % (100 * m[640:1000, 180:540].mean()))
        # also a plain hue/sat band rule for the ochre floor
        h, s, v = hsv(img)
        band = (h >= 18) & (h < 42) & (s > 0.36) & (s < 0.75) & (v > 0.55)
        print("ochre/peach band (hue18-42,S.36-.75,V>.55) %.1f %%" % (100 * band.mean()))
