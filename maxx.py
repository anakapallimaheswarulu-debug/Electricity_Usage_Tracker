import pymupdf
d=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
imgpages={i+1 for i,p in enumerate(d) if p.get_images(full=True)}
for i,p in enumerate(d):
    pno=i+1
    if pno in imgpages or pno<=2: continue
    for b in p.get_text("dict")["blocks"]:
        if b.get("type")!=0: continue
        spans=[s for l in b["lines"] for s in l["spans"] if s["text"].strip()]
        if not spans: continue
        y1=b["bbox"][3]
        if y1>730: continue
        size=round(spans[0]["size"],1); font=spans[0]["font"]
        if abs(size-12)<0.1 or (abs(size-14)<0.1 and "Bold" in font):
            print(f"p{pno:02d} x0={b['bbox'][0]:.1f} x1={b['bbox'][2]:.1f} y={b['bbox'][1]:.1f}-{y1:.1f} nlines={len(b['lines'])} size={size} {''.join(s['text'] for s in spans)[:50]!r}")
