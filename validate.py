import pymupdf, itertools, collections, hashlib
src=pymupdf.open("source_BEFORE_ONE_LAST.pdf"); out=pymupdf.open("FLUTTER_BEFORE_ONE_LAST_14pt.pdf")
ELIGIBLE=[3,4,5,6,7,11,12,13,14,16,22,24,26,27,28,31,32,33,35,37,38,39,40,41,42,43,44,49,50,51]
IMG_PAGES={1,8,9,10,15,17,18,19,20,21,23,25,29,30,34,36,45,46,47,48}
issues=0
for pno in ELIGIBLE:
    p=out[pno-1]; lines=[]; sizes=collections.Counter(); bold14=0; b12=0
    for b in p.get_text("dict")["blocks"]:
        if b.get("type")!=0: continue
        for l in b.get("lines",[]):
            spans=[s for s in l["spans"] if s["text"].strip()]
            if not spans: continue
            if l["bbox"][3]>730: continue
            lines.append((pymupdf.Rect(l["bbox"]), "".join(s["text"] for s in spans)[:40]))
            for s in spans:
                sizes[round(s["size"],1)]+=len(s["text"])
                if abs(s["size"]-12)<0.1: b12+=1
                if abs(s["size"]-14)<0.1 and "Bold" in s["font"]: bold14+=1
    maxx=max(l[0].x1 for l in lines); maxy=max(l[0].y1 for l in lines)
    if maxx>558.4 or maxy>726.5:
        print("BOUNDS p",pno,"maxx",maxx,"maxy",maxy); issues+=1
    if b12 or bold14:
        print("SIZE p",pno,"b12",b12,"bold14",bold14); issues+=1
    for (r1,t1),(r2,t2) in itertools.combinations(lines,2):
        inter=r1 & r2
        if inter.is_empty: continue
        if inter.width>1.0 and inter.height>1.0:
            print("OVERLAP p",pno,[round(x,1) for x in r1],[round(x,1) for x in r2],repr(t1),repr(t2)); issues+=1
    print(f"p{pno:02d} lines={len(lines)} maxx={maxx:.1f} maxy={maxy:.1f} sizes={dict(sizes)}")
print("issues",issues)
# untouched pages render hash
for pno in sorted(IMG_PAGES|{1,2}):
    a=src[pno-1].get_pixmap(dpi=80,colorspace=pymupdf.csRGB).samples
    b=out[pno-1].get_pixmap(dpi=80,colorspace=pymupdf.csRGB).samples
    if a!=b: print("UNTOUCHED DIFF p",pno)
print("untouched compare done")
