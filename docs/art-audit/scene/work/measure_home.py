import sys, numpy as np; sys.path.insert(0, sys.argv[1]); import png
src=sys.argv[2]; im=png.read(src); H,W,_=im.shape
h,s,v=png.hsv(im)
def pct(m): return 100.0*m.sum()/m.size
print("== hue bands (S>0.25,V>0.2) for", src.split('/')[-2])
sat=(s>0.25)&(v>0.2)
bands=[("red/terracotta 0-20",0,20),("orange/ochre 20-50",20,50),("yellow 50-70",50,70),("green 70-160",70,160),("teal/cyan 160-200",160,200),("blue 200-260",200,260),("magenta/maroon 260-360",260,360)]
for n,a,b in bands: print(f"  {n:24s} {pct(sat&(h>=a)&(h<b)):5.1f} %")
print(f"  neutral (S<=0.25 or V<=0.2) {pct(~sat):5.1f} %   mean S {s.mean():.2f} mean V {v.mean():.2f}")
# coarse quantisation: top colours
q=(im//24).reshape(-1,3).astype(np.int64); keys=q[:,0]*10000+q[:,1]*100+q[:,2]
u,c=np.unique(keys,return_counts=True); order=np.argsort(-c)[:18]
print("== top colour bins (bin centre hex, share)")
for i in order:
    k=u[i]; r,g,b=(k//10000)*24+12,((k//100)%100)*24+12,(k%100)*24+12
    print(f"  #{r:02X}{g:02X}{b:02X} {100*c[i]/len(keys):5.1f} %")
# samples at named points
pts={"tile light (360,760)":(360,760),"tile dark (250,900)":(250,900),"tile in shadow (560,430)":(560,430),"tile light shadow (300,650)":(300,650),
 "teal wall (560,120)":(560,120),"wall dado red (100,520)":(100,520),"wall top cream (300,300)":(300,300),"outside sand top-left (60,60)":(60,60),
 "courtyard sand (680,440)":(680,440),"road asphalt (60,1200)":(60,1200),"kerb yellow (120,1150)":(120,1150),"charpai top (560,600)":(560,600),
 "charpai wood (470,640)":(470,640),"galla top (230,640)":(230,640),"galla front red (200,700)":(200,700),"chai counter top (300,560)":(300,560),
 "skin head (360,640)":(360,640),"waiter yellow shirt (370,665)":(370,665),"plate (355,690)":(355,690),"blue cap (460,650)":(460,650),"navy kurta (460,690)":(460,690),
 "cook white kurta (215,520)":(215,520),"cashier green shirt (150,600)":(150,600),"pink dupatta cook (390,380)":(390,380),"diner yellow (570,620)":(570,620),"awning blue (60,860)":(60,860),"flower pot red (300,1130)":(300,1130)}
print("== samples (5x5 mean)")
S={}
for n,(x,y) in pts.items():
    p=im[y-2:y+3,x-2:x+3].reshape(-1,3).mean(0); S[n]=p; print(f"  {n:34s} #{int(p[0]):02X}{int(p[1]):02X}{int(p[2]):02X}")
print("== contrast people vs floor (WCAG ratio / dE)")
floor=["tile light (360,760)","tile dark (250,900)","tile in shadow (560,430)"]
for a in ["skin head (360,640)","waiter yellow shirt (370,665)","plate (355,690)","blue cap (460,650)","navy kurta (460,690)","cook white kurta (215,520)","cashier green shirt (150,600)","diner yellow (570,620)","charpai top (560,600)","charpai wood (470,640)","chai counter top (300,560)","galla top (230,640)"]:
    print("  "+a[:26].ljust(27)+"  ".join(f"vs {f.split(' (')[0]}: {png.contrast(S[a],S[f]):.2f} / dE {png.dE(S[a],S[f]):4.1f}" for f in floor))
print("== wall top vs outside")
for a,b in [("wall top cream (300,300)","outside sand top-left (60,60)"),("wall top cream (300,300)","courtyard sand (680,440)"),("tile light (360,760)","courtyard sand (680,440)"),("teal wall (560,120)","tile light (360,760)"),("charpai top (560,600)","plate (355,690)")]:
    print(f"  {a} vs {b}: ratio {png.contrast(S[a],S[b]):.2f} dE {png.dE(S[a],S[b]):.1f}")
# region shares by colour class (dE to samples)
lab=png.rgb2lab(im.reshape(-1,3).astype(float))
classes={"floor tiles":[S["tile light (360,760)"],S["tile dark (250,900)"],S["tile in shadow (560,430)"],S["tile light shadow (300,650)"]],
 "teal wall":[S["teal wall (560,120)"]],"cream/sand (wall tops, outside)":[S["wall top cream (300,300)"],S["outside sand top-left (60,60)"],S["courtyard sand (680,440)"]],
 "charpai/white tops":[S["charpai top (560,600)"],S["plate (355,690)"]],"road grey":[S["road asphalt (60,1200)"]]}
best=np.full(len(lab),99.0); lbl=np.full(len(lab),-1)
names=list(classes)
for i,n in enumerate(names):
    for ref in classes[n]:
        d=np.linalg.norm(lab-png.rgb2lab(np.array(ref,float)),axis=1); m=d<best; best[m]=d[m]; lbl[m]=i
print("== rough area shares (nearest sample, dE<14)")
for i,n in enumerate(names): print(f"  {n:34s} {100*((lbl==i)&(best<14)).sum()/len(lab):5.1f} %")
print(f"  {'everything else (people, props, signs)':34s} {100*(best>=14).sum()/len(lab):5.1f} %")
