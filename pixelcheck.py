import pymupdf, collections
d=pymupdf.open("FLUTTER_BEFORE_ONE_LAST_14pt.pdf")
for pno in [6,11,35,39]:
    p=d[pno-1]; pix=p.get_pixmap(dpi=144,colorspace=pymupdf.csRGB)
    print("="*30,"PAGE",pno)
    for dr in p.get_drawings():
        f=dr.get("fill")
        if f is None: continue
        r=dr["rect"]
        if not (r.width>300 and r.height>10 and max(f)-min(f)<0.02 and max(f)<0.985): continue
        if r.y1<600: continue
        cols=collections.Counter()
        for fx in [0.1,0.3,0.5,0.7,0.9]:
            for fy in [0.2,0.5,0.8]:
                x=int((r.x0+(r.x1-r.x0)*fx)*144/72); y=int((r.y0+(r.y1-r.y0)*fy)*144/72)
                if 0<=x<pix.width and 0<=y<pix.height:
                    cols[pix.pixel(x,y)]+=1
        print("rect",[round(x,1) for x in r],"colors",cols.most_common(4))
