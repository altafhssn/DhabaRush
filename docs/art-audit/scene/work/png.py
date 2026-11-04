# Minimal PNG reader/writer (8-bit RGB/RGBA, non-interlaced) using zlib+numpy. No PIL.
import zlib, struct, numpy as np
def read(path):
    d = open(path,'rb').read(); assert d[:8]==b'\x89PNG\r\n\x1a\n'
    p=8; idat=b''; w=h=0; ct=0; bd=8
    while p < len(d):
        n,=struct.unpack('>I',d[p:p+4]); t=d[p+4:p+8]; c=d[p+8:p+8+n]; p+=12+n
        if t==b'IHDR': w,h,bd,ct,_,_,il=struct.unpack('>IIBBBBB',c); assert bd==8 and il==0, (bd,il)
        elif t==b'IDAT': idat+=c
        elif t==b'IEND': break
    ch={2:3,6:4,0:1,4:2}[ct]
    raw=np.frombuffer(zlib.decompress(idat),dtype=np.uint8)
    stride=w*ch; out=np.zeros((h,stride),dtype=np.uint8); prev=np.zeros(stride,dtype=np.int32)
    pos=0
    for y in range(h):
        f=raw[pos]; line=raw[pos+1:pos+1+stride].astype(np.int32); pos+=1+stride
        if f==0: cur=line
        elif f==1:
            cur=line.copy()
            for i in range(ch,stride): cur[i]=(cur[i]+cur[i-ch])&255
        elif f==2: cur=(line+prev)&255
        elif f==3:
            cur=line.copy()
            for i in range(stride):
                a=cur[i-ch] if i>=ch else 0; cur[i]=(cur[i]+((a+prev[i])>>1))&255
        elif f==4:
            cur=line.copy()
            for i in range(stride):
                a=cur[i-ch] if i>=ch else 0; b=prev[i]; c=prev[i-ch] if i>=ch else 0
                pa=abs(b-c); pb=abs(a-c); pc=abs(a+b-2*c)
                pr=a if (pa<=pb and pa<=pc) else (b if pb<=pc else c)
                cur[i]=(cur[i]+pr)&255
        out[y]=cur; prev=cur
    img=out.reshape(h,w,ch)
    return img[:,:,:3].copy()
def write(path,img):
    h,w,_=img.shape; rows=np.concatenate([np.zeros((h,1),np.uint8),img.reshape(h,-1)],axis=1).tobytes()
    def chunk(t,c): return struct.pack('>I',len(c))+t+c+struct.pack('>I',zlib.crc32(t+c)&0xffffffff)
    open(path,'wb').write(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',w,h,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(rows,6))+chunk(b'IEND',b''))
def srgb2lin(c):
    c=c/255.0; return np.where(c<=0.04045,c/12.92,((c+0.055)/1.055)**2.4)
def lum(rgb):
    l=srgb2lin(np.asarray(rgb,dtype=float)); return 0.2126*l[...,0]+0.7152*l[...,1]+0.0722*l[...,2]
def contrast(a,b):
    la,lb=lum(a),lum(b); hi,lo=max(la,lb),min(la,lb); return (hi+0.05)/(lo+0.05)
def rgb2lab(rgb):
    l=srgb2lin(np.asarray(rgb,dtype=float))
    M=np.array([[0.4124,0.3576,0.1805],[0.2126,0.7152,0.0722],[0.0193,0.1192,0.9505]])
    xyz=l@M.T; xyz=xyz/np.array([0.95047,1.0,1.08883])
    f=np.where(xyz>0.008856,np.cbrt(xyz),7.787*xyz+16/116)
    return np.stack([116*f[...,1]-16,500*(f[...,0]-f[...,1]),200*(f[...,1]-f[...,2])],axis=-1)
def dE(a,b): return float(np.linalg.norm(rgb2lab(a)-rgb2lab(b)))
def hsv(img):
    x=img.astype(float)/255; mx=x.max(-1); mn=x.min(-1); d=mx-mn
    h=np.zeros_like(mx); m=d>1e-6
    r,g,b=x[...,0],x[...,1],x[...,2]
    i=(mx==r)&m; h[i]=((g-b)[i]/d[i])%6
    i=(mx==g)&m&~(mx==r); h[i]=(b-r)[i]/d[i]+2
    i=(mx==b)&m&~(mx==r)&~(mx==g); h[i]=(r-g)[i]/d[i]+4
    h=h*60; s=np.where(mx>0,d/np.maximum(mx,1e-6),0); return h,s,mx
