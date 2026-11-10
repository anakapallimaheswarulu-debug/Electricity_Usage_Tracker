import pymupdf
d=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
for pno in [2,3,13,14,48,49]:
    p=d[pno]; print("="*60,"PAGE",pno+1)
    for b in p.get_text("dict")["blocks"]:
        if b.get("type")!=0: continue
        spans=[s for l in b["lines"] for s in l["spans"] if s["text"].strip()]
        if not spans: continue
        size=round(spans[0]["size"],1); font=spans[0]["font"]
        if abs(size-12)>0.1 and not (abs(size-14)<0.1 and "Bold" in font): continue
        print("block size",size,font,"bbox",[round(x,1) for x in b["bbox"]])
        for l in b["lines"][:8]:
            print("  x0=%.1f x1=%.1f y0=%.1f text=%r"%(l["bbox"][0],l["bbox"][2],l["bbox"][1],l["spans"][0]["text"][:60]))
