"""Metric-only stand-ins for the fallback fonts (build optimisation, 0.3.5).

The game's text font is Baloo 2 (ui/main_font.tres). Its fallback chain also
lists NotoSans, NotoSansSymbols and NotoSansSymbols2, but every character the
game shows (English, Hindi, the rupee sign) is already in Baloo 2, so those
three never draw a glyph. They still matter for one thing: Godot sizes a text
line by the tallest font in the chain (NotoSansSymbols' ascent, Symbols2's
descent), so removing them would move text.

This script writes a stand-in for each one that keeps the font's vertical
metrics (head, hhea, OS/2, name, post header) and nothing else: one empty
.notdef glyph and an empty cmap. Line heights stay identical; the 3.3 MB of
glyph data (about 2.2 MB in the APK, 3.6 MB of RAM) goes. A character outside
Baloo 2 (none today) would come from the phone's own fonts
(allow_system_fallback is on). NotoSansDevanagari is NOT replaced.

The full fonts are kept in tools/fonts/full/ (.gdignore'd, never exported).
To undo: copy tools/fonts/full/*.ttf back over assets/fonts/.

Usage (any Python 3, no dependencies):
    python3 tools/fonts/make_font_standins.py            # all three
    python3 tools/fonts/make_font_standins.py SRC DST    # one font
Noto fonts are OFL 1.1 (assets/fonts/OFL.txt); the stand-ins keep the name
table and stay under the same licence.
"""
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
FONTS = ["NotoSans.ttf", "NotoSansSymbols.ttf", "NotoSansSymbols2.ttf"]


def _tables(d):
    n = struct.unpack_from(">H", d, 4)[0]
    t = {}
    for i in range(n):
        tag, _cs, off, ln = struct.unpack_from(">4sIII", d, 12 + 16 * i)
        t[tag.decode("latin1")] = (off, ln)
    return t


def _csum(b):
    b = b + b"\0" * ((4 - len(b) % 4) % 4)
    return sum(struct.unpack(">%dI" % (len(b) // 4), b)) & 0xFFFFFFFF


def standin(src, dst):
    d = open(src, "rb").read()
    t = _tables(d)

    def tb(tag):
        o, ln = t[tag]
        return bytearray(d[o:o + ln])

    head = tb("head")
    struct.pack_into(">I", head, 8, 0)        # checkSumAdjustment
    struct.pack_into(">h", head, 50, 0)       # indexToLocFormat: short
    hhea = tb("hhea")
    struct.pack_into(">H", hhea, 34, 1)       # numberOfHMetrics
    maxp = tb("maxp")
    struct.pack_into(">H", maxp, 4, 1)        # numGlyphs
    if len(maxp) >= 32:
        for off in range(6, 32, 2):
            struct.pack_into(">H", maxp, off, 0)
        struct.pack_into(">H", maxp, 14, 2)   # maxZones
    os2 = tb("OS/2")
    adv = struct.unpack_from(">H", tb("hmtx"), 0)[0]
    hmtx = struct.pack(">Hh", adv, 0)
    loca = struct.pack(">HH", 0, 0)
    glyf = b""
    # cmap: one (3,1) format 4 subtable holding only the 0xFFFF end segment.
    f4 = struct.pack(">HHHHHHH", 4, 16 + 8, 0, 2, 2, 0, 0) + struct.pack(">H", 0xFFFF) + struct.pack(">H", 0) \
        + struct.pack(">H", 0xFFFF) + struct.pack(">h", 1) + struct.pack(">H", 0)
    cmap = struct.pack(">HHHHI", 0, 1, 3, 1, 12) + f4
    name = bytes(tb("name"))
    post = tb("post")[:32]
    struct.pack_into(">I", post, 0, 0x00030000)  # version 3: no glyph names
    new = {"head": bytes(head), "hhea": bytes(hhea), "maxp": bytes(maxp), "OS/2": bytes(os2), "hmtx": hmtx,
           "loca": loca, "glyf": glyf, "cmap": cmap, "name": name, "post": bytes(post)}
    tags = sorted(new)
    n = len(tags)
    es = 1
    while (es << 1) <= n:
        es <<= 1
    hdr = struct.pack(">IHHHH", 0x00010000, n, es * 16, es.bit_length() - 1, n * 16 - es * 16)
    off = 12 + 16 * n
    dirs = b""
    body = b""
    for tg in tags:
        b = new[tg]
        dirs += struct.pack(">4sIII", tg.encode("latin1"), _csum(b), off + len(body), len(b))
        body += b + b"\0" * ((4 - len(b) % 4) % 4)
    out = hdr + dirs + body
    with open(dst, "wb") as f:
        f.write(out)
    print("%s -> %s (%d bytes, from %d)" % (os.path.basename(src), dst, len(out), len(d)))


def main(argv):
    if len(argv) == 3:
        standin(argv[1], argv[2])
        return
    for fn in FONTS:
        standin(os.path.join(HERE, "full", fn), os.path.join(ROOT, "assets", "fonts", fn))


if __name__ == "__main__":
    main(sys.argv)
