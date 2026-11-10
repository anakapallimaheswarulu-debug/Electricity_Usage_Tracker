import pymupdf
d=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
imgpages={i+1 for i,p in enumerate(d) if p.get_images(full=True)}
for i,p in enumerate(d):
    pno=i+1
    if pno in imgpages or pno<=2: continue
    for b in p.get_text("dict")["blocks"]:
        if b.get("type")!=0: continue
        lines=b.get("lines",[])
        spans=[s for l in lines for s in l["spans"] if s["text"].strip()]
        if not spans: continue
        y1=b["bbox"][3]
        if y1>730: continue
        size=round(spans[0]["size"],1); font=spans[0]["font"]
        if not (abs(size-12)<0.1 or (abs(size-14)<0.1 and "Bold" in font)): continue
        styles=set()
        for s in spans:
            t=s["text"].strip()
            if not t or t=="•": continue
            styles.add((s["font"],round(s["size"],1),s["color"],bool(s["flags"]&16),bool(s["flags"]&2)))
        if len(styles)>1:
            print("p",pno,"y",round(b["bbox"][1],1),"styles",styles)
            for s in spans[:8]: print("   ",repr(s["text"][:40]),s["font"],s["size"],hex(s["color"]),s["flags"])
