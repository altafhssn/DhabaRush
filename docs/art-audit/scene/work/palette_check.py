import sys, numpy as np; sys.path.insert(0, sys.argv[1]); import png
hexes=[l.strip() for l in open(sys.argv[2]) if l.strip()]
names="ASPHALT LINE DUST DUST_DARK GRASS LEAF TRUNK WOOD TIN RUST CREAM TEAL RED YELLOW GREEN BLUE ORANGE SKIN1 SKIN2 HAIR WHITE SAFFRON PINK PURPLE STEEL DARK_STEEL CLAY FIRE CHAI DAL ROTI ROPE CASH GLASS TYRE BULB MUD DARK_GREEN NAVY MAROON SLATE GRAVEL NEON_PINK NEON_CYAN BRICK TARP PAINT_YELLOW LEAF_LIGHT TILE_A TILE_B PLASTER DADO BRICK_RED MORTAR KURTA JACKET GOLD GOLD_DARK NOTE NOTE_DARK MARKER_TOP MARIGOLD MARIGOLD_DARK SKIN_L SKIN_M BLUSH DENIM KHAKI ROAD PAVER KERB LIME LIME_DARK FOLIAGE COW HORN BAMBOO CONCRETE ROOF_RED TIN_BLUE DUST_LT DUST_LOT TANK MANGO WALL_BLUE WALL_PINK TRACK TRUCK_TEAL SMOKE NEEM NEEM_LT POLE WALL_GREEN WALL_CREAM WHITEWASH DOG".split()
rgb=np.array([[int(h[i:i+2],16) for i in (0,2,4)] for h in hexes],float); lab=png.rgb2lab(rgb)
print(len(hexes),"swatches")
pairs=[]
for i in range(len(hexes)):
    for j in range(i+1,len(hexes)):
        d=np.linalg.norm(lab[i]-lab[j]); 
        if d<7: pairs.append((d,i,j))
pairs.sort(); print("== near-duplicate pairs (dE<7):",len(pairs))
for d,i,j in pairs: print(f"  dE {d:4.1f}  {i:2d} {names[i]:13s} #{hexes[i]}   {j:2d} {names[j]:13s} #{hexes[j]}")
h,s,v=png.hsv(rgb.reshape(1,-1,3)); h=h[0]; s=s[0]; v=v[0]
print("== hue families (saturated S>0.3)")
bands=[("red 0-20",0,20),("orange/ochre 20-50",20,50),("yellow 50-70",50,70),("green 70-160",70,160),("teal/cyan 160-200",160,200),("blue 200-260",200,260),("purple/pink 260-360",260,360)]
for n,a,b in bands:
    idx=[i for i in range(len(hexes)) if s[i]>0.3 and a<=h[i]<b]; print(f"  {n:20s} {len(idx):2d}: "+" ".join(names[i] for i in idx))
idx=[i for i in range(len(hexes)) if s[i]<=0.3]; print(f"  {'neutral S<=0.3':20s} {len(idx):2d}: "+" ".join(names[i] for i in idx))
