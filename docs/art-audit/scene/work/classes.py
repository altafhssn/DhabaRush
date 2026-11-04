import sys; sys.path.insert(0,sys.argv[1]); import png, numpy as np
im=png.read(sys.argv[2]); h,s,v=png.hsv(im); n=h.size
def hx(p): return "#%02X%02X%02X"%tuple(int(q) for q in p)
C=[("ochre / peach (floor tiles, wood, skin)",(h>=18)&(h<42)&(s>=0.36)&(s<0.75)&(v>0.55)),
   ("pale lemon (yard sand, kerb, plaster band)",(v>0.88)&(s<0.45)&(s>=0.12)&(h>=35)&(h<75)),
   ("white tops (charpais, plates, kurtas, galla)",(v>0.85)&(s<0.12)),
   ("teal (walls)",(h>=150)&(h<200)&(s>0.35)&(v>0.2)),
   ("grey (road, tin, steel)",(s<0.2)&(v>=0.25)&(v<=0.85)),
   ("dark (hair, ink, deep shadow)",(v<0.25)),
   ("red / maroon accents",((h<15)|(h>=340))&(s>0.5)&(v>0.3)),
   ("yellow / marigold accents",(h>=42)&(h<62)&(s>=0.55)&(v>0.6)),
   ("green (leaves, shirts)",(h>=70)&(h<150)&(s>0.35)&(v>0.3)),
   ("blue (caps, denim, awning)",(h>=200)&(h<260)&(s>0.3)&(v>0.3)),
   ("pink / purple",(h>=260)&(h<340)&(s>0.3)&(v>0.3))]
used=np.zeros(h.shape,bool); rows=[]
for name,m in C:
    m=m&~used; used|=m; share=100*m.mean(); col=im[m].mean(0) if m.any() else np.zeros(3); rows.append((name,share,hx(col)))
rows.append(("other",100*(~used).mean(),hx(im[~used].mean(0))))
for r in rows: print(f"{r[1]:5.1f} %  {r[2]}  {r[0]}")
