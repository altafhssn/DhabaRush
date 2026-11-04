import os, struct
A = "/Users/almeer/Documents/HighwayDhaba/assets/audio"
tot = 0
for fn in sorted(os.listdir(A)):
    p = os.path.join(A, fn)
    if fn.endswith(".wav"):
        d = open(p, "rb").read()
        i = 12; fmt = None
        while i < len(d) - 8:
            cid, ln = d[i:i+4], struct.unpack("<I", d[i+4:i+8])[0]
            if cid == b"fmt ":
                tag, ch, sr, br, ba, bits = struct.unpack("<HHIIHH", d[i+8:i+24]); fmt = (tag, ch, sr, bits)
            i += 8 + ln + (ln & 1)
        tot += len(d)
        print("%-22s %8d B  fmt=%s ch=%d %d Hz %d-bit" % (fn, len(d), fmt[0], fmt[1], fmt[2], fmt[3]))
    elif fn.endswith(".ogg"):
        tot += os.path.getsize(p)
        print("%-22s %8d B  ogg" % (fn, os.path.getsize(p)))
    elif not fn.endswith(".import"):
        print("other:", fn, os.path.getsize(p))
print("total audio source bytes:", tot)
