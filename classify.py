import pymupdf, collections
d=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
for i,p in enumerate(d):
    txt=p.get_text("dict")
    imgblocks=[b for b in txt["blocks"] if b.get("type")==1]
    imgs=p.get_images(full=True)
    # code-like mono text
    mono=0; body12=0; heads14=0; heads16=0; body11=0; size9=0; maxy=0; miny=9999
    for b in txt["blocks"]:
        for l in b.get("lines",[]):
            for s in l["spans"]:
                t=s["text"].strip()
                if not t: continue
                if s["font"].startswith("DejaVu") or s["font"].startswith("Consol"): mono+=len(t)
                if abs(s["size"]-12)<0.1: body12+=len(t)
                if abs(s["size"]-14)<0.1: heads14+=len(t)
                if abs(s["size"]-16)<0.1: heads16+=len(t)
                if abs(s["size"]-11)<0.1: body11+=len(t)
                if abs(s["size"]-9)<0.1: size9+=len(t)
            if b.get("type")==0:
                maxy=max(maxy,l["bbox"][3]); miny=min(miny,l["bbox"][1])
    imgarea=sum((b["bbox"][2]-b["bbox"][0])*(b["bbox"][3]-b["bbox"][1]) for b in imgblocks)
    # drawings with fill
    fills=[dr for dr in p.get_drawings() if dr.get("fill") is not None and dr["rect"].height>5]
    codefill=sum(1 for dr in fills if dr["rect"].height>15 and dr["rect"].width>200)
    print(f"p{i+1:02d} imgblk={len(imgblocks)} imgs={len(imgs)} imgarea={int(imgarea)} fills={len(fills)} codefill={codefill} mono={mono} b12={body12} h14={heads14} h16={heads16} b11={body11} s9={size9} textY={miny:.0f}-{maxy:.0f}")
