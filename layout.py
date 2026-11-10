import pymupdf
d=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
for pno in [2,3,4,5,13,48]:
    p=d[pno]
    print("="*70); print("PAGE",pno+1)
    print("fonts:", [(f[3],f[4]) for f in p.get_fonts(full=True)])
    # line baselines and spacing for first few blocks
    for b in p.get_text("dict")["blocks"][:8]:
        if b.get("type")!=0: continue
        ys=[round(l["bbox"][3],2) for l in b.get("lines",[])]
        print("block",[round(x,1) for x in b["bbox"]],"line bottoms",ys[:8], "diffs",[round(ys[i+1]-ys[i],2) for i in range(min(len(ys)-1,6))])
    print("drawings:")
    for dr in p.get_drawings()[:12]:
        print(" ", dr.get("fill"), [round(x,1) for x in dr["rect"]], len(dr["items"]))
