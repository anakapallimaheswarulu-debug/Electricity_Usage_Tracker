import pymupdf
d=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
imgpages={i+1 for i,p in enumerate(d) if p.get_images(full=True)}
for i,p in enumerate(d):
    pno=i+1
    if pno in imgpages or pno<=2: continue
    blocks=p.get_text("dict")["blocks"]
    code_b=[]; body_b=[]; head_b=[]; other_b=[]
    text_bottom=0; code_bottom=0
    has_code=False
    for b in blocks:
        if b.get("type")!=0: continue
        # classify block by dominant font/size
        spans=[s for l in b["lines"] for s in l["spans"] if s["text"].strip()]
        if not spans: continue
        txt="".join(s["text"] for s in spans)
        y0,y1=b["bbox"][1],b["bbox"][3]
        if y1>730: continue # footer/number
        font=spans[0]["font"]; size=round(spans[0]["size"],1)
        if "Mono" in font or "Consol" in font or size<=10:
            code_b.append(b); code_bottom=max(code_bottom,y1); has_code=True
        elif size>=13.5:
            head_b.append(b)
        elif abs(size-12)<0.1:
            body_b.append(b)
        else:
            other_b.append(b)
        text_bottom=max(text_bottom,y1)
    def h(bs): return sum(b["bbox"][3]-b["bbox"][1] for b in bs)
    bodyh=h(body_b); headh=h(head_b); codeh=h(code_b); otherh=h(other_b)
    # conservative growth: body 1.36x, head 1.14x
    newh=bodyh*1.36+headh*1.14+codeh+otherh
    oldh=bodyh+headh+codeh+otherh
    top=55.2
    free=720-text_bottom
    need=newh-oldh
    print(f"p{pno:02d} code={has_code} body={len(body_b)} head={len(head_b)} other={len(other_b)} oldh={oldh:.0f} need={need:.0f} free={free:.0f} bottom={text_bottom:.0f} {'OK' if need<=free else 'TIGHT'}")
