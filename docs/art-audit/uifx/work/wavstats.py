import sys, wave, struct, math, os, glob
d = sys.argv[1]
print("file\tdur_s\tpeak_dBFS\trms_dBFS\tstart_abs\tend_abs\tsize_B")
for f in sorted(glob.glob(os.path.join(d, "*.wav"))):
    w = wave.open(f, "rb")
    n = w.getnframes(); sr = w.getframerate(); ch = w.getnchannels(); sw = w.getsampwidth()
    raw = w.readframes(n); w.close()
    fmt = "<%dh" % (n * ch)
    s = struct.unpack(fmt, raw)
    peak = max(abs(x) for x in s) / 32768.0
    rms = math.sqrt(sum(x * x for x in s) / len(s)) / 32768.0
    pk = 20 * math.log10(peak) if peak > 0 else -99
    rm = 20 * math.log10(rms) if rms > 0 else -99
    print("%s\t%.2f\t%.1f\t%.1f\t%d\t%d\t%d" % (os.path.basename(f), n / sr, pk, rm, abs(s[0]), abs(s[-1]), os.path.getsize(f)))
