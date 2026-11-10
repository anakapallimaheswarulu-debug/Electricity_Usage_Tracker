import pymupdf
for fn in ["source_BEFORE_ONE_LAST.pdf","FLUTTER_BEFORE_ONE_LAST_14pt.pdf"]:
    d=pymupdf.open(fn); print("="*40,fn)
    for pno in [6,11,35,39]:
        p=d[pno-1]; fills=[]
        for dr in p.get_drawings():
            f=dr.get("fill")
            if f is None: continue
            r=dr["rect"]
            if r.width>300 and r.height>10 and max(f)-min(f)<0.02 and max(f)<0.985:
                fills.append((round(r.x0,1),round(r.y0,1),round(r.x1,1),round(r.y1,1)))
        print("p",pno,"gray fills",fills)
