import pymupdf
d=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
imgpages={i+1 for i,p in enumerate(d) if p.get_images(full=True)}
for i,p in enumerate(d):
    pno=i+1
    if pno in imgpages or pno<=2: continue
    print("="*80); print("PAGE",pno)
    for b in sorted([b for b in p.get_text("dict")["blocks"] if b.get("type")==0], key=lambda b:b["bbox"][1]):
        spans=[s for l in b["lines"] for s in l["spans"] if s["text"].strip()]
        if not spans: continue
        y0,y1=b["bbox"][1],b["bbox"][3]
        if y1>730: continue
        font=spans[0]["font"]; size=round(spans[0]["size"],1)
        typ="CODE" if ("Mono" in font or "Consol" in font or size<=10) else ("HEAD" if size>=13.5 else ("BODY" if abs(size-12)<0.1 else "OTHER"))
        txt=" ".join(s["text"] for s in spans).replace("\xa0"," ").replace("\xad","-")
        print(f" {typ:5s} y={y0:6.1f}-{y1:6.1f} x={b['bbox'][0]:6.1f}-{b['bbox'][2]:6.1f} n={len(b['lines'])} sz={size} {txt[:80]!r}")
