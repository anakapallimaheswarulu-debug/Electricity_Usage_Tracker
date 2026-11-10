import pymupdf
d=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
for pno in [5,7,26,27,35,37,39,42,50,51]:
    p=d[pno-1]; print("="*50,"PAGE",pno)
    drs=[dr for dr in p.get_drawings() if dr["rect"].x0>40 and dr["rect"].x1<580 and dr["rect"].y1<730 and dr["rect"].y0>40]
    print("DRAWINGS",len(drs))
    for dr in drs:
        r=dr["rect"]
        print("  dr",[round(x,1) for x in r],"fill",dr.get("fill"),"col",dr.get("color"),"w",round(dr.get("width") or 0,1),"items",len(dr["items"]))
    for b in p.get_text("dict")["blocks"]:
        if b.get("type")!=0: continue
        spans=[s for l in b["lines"] for s in l["spans"] if s["text"].strip()]
        if not spans: continue
        sz=round(spans[0]["size"],1)
        if abs(sz-11)<0.1 or sz<10:
            print("  TXT",[round(x,1) for x in b["bbox"]],sz,"/".join(sorted({s['font'] for s in spans})),"".join(s['text'] for s in spans)[:50].replace('\xa0',' '))
