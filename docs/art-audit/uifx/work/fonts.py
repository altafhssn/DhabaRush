import struct, sys, os, glob, re
def tables(b):
    n = struct.unpack(">H", b[4:6])[0]
    t = {}
    for i in range(n):
        tag, cs, off, ln = struct.unpack(">4sIII", b[12+16*i:28+16*i])
        t[tag.decode('latin1')] = (off, ln)
    return t
def cmap(b, t):
    if 'cmap' not in t: return set()
    off, ln = t['cmap']; m = set()
    ntab = struct.unpack(">H", b[off+2:off+4])[0]
    for i in range(ntab):
        pid, eid, so = struct.unpack(">HHI", b[off+4+8*i:off+12+8*i])
        sub = off+so; fmt = struct.unpack(">H", b[sub:sub+2])[0]
        if fmt == 4:
            segx2 = struct.unpack(">H", b[sub+6:sub+8])[0]; seg = segx2//2
            ends = struct.unpack(">%dH"%seg, b[sub+14:sub+14+segx2])
            starts = struct.unpack(">%dH"%seg, b[sub+16+segx2:sub+16+2*segx2])
            for s,e in zip(starts, ends):
                if s == 0xFFFF: continue
                for c in range(s, e+1): m.add(c)
        elif fmt == 12:
            ngroups = struct.unpack(">I", b[sub+12:sub+16])[0]
            for g in range(ngroups):
                s,e,_ = struct.unpack(">III", b[sub+16+12*g:sub+28+12*g])
                for c in range(s, min(e, 0x2FFFF)+1): m.add(c)
    return m
def fvar(b, t):
    if 'fvar' not in t: return []
    off, ln = t['fvar']
    aoff, ac, asz = struct.unpack(">HHH", b[off+4:off+10])
    out = []
    for i in range(ac):
        a = off+aoff+asz*i
        tag = b[a:a+4].decode('latin1'); mn, df, mx = struct.unpack(">iii", b[a+4:a+16])
        out.append((tag, mn/65536, df/65536, mx/65536))
    return out
# characters used in player-facing text
used = set()
for f in glob.glob('/Users/almeer/Documents/HighwayDhaba/scripts/**/*.gd', recursive=True) + glob.glob('/Users/almeer/Documents/HighwayDhaba/i18n/*.po'):
    try: s = open(f, encoding='utf-8').read()
    except: continue
    for ch in s:
        if ord(ch) > 126: used.add(ch)
fonts = {}
for f in sorted(glob.glob('/Users/almeer/Documents/HighwayDhaba/assets/fonts/*.ttf')):
    b = open(f,'rb').read(); t = tables(b); m = cmap(b, t)
    fonts[os.path.basename(f)] = m
    lat = sum(1 for c in m if 0x20 <= c <= 0x7E); dev = sum(1 for c in m if 0x900 <= c <= 0x97F)
    print("%-26s %7d B  tables=%d  glyphs(cmap)=%d  Latin=%d  Devanagari=%d  fvar=%s  GSUB=%s  GPOS=%s  rupee=%s" % (
        os.path.basename(f), len(b), len(t), len(m), lat, dev, fvar(b,t), 'GSUB' in t, 'GPOS' in t, 0x20B9 in m))
    big = sorted(t.items(), key=lambda kv: -kv[1][1])[:4]
    print("    biggest tables:", ", ".join("%s %d B" % (k, v[1]) for k,v in big))
baloo = fonts['Baloo2.ttf']; dev = fonts['NotoSansDevanagari.ttf']
miss = sorted(c for c in used if ord(c) not in baloo)
print("\nnon-ASCII characters used in scripts + i18n: %d distinct" % len(used))
print("missing from Baloo2: %d ->" % len(miss), " ".join("%s(U+%04X%s)" % (c, ord(c), " devanagari-ok" if ord(c) in dev else "") for c in miss))
