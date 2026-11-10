import pymupdf
d=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
for pno in [2,3,4,13,48]:
    p=d[pno]
    print("="*60,"PAGE",pno+1)
    n=0
    for b in p.get_text("dict")["blocks"]:
        if b.get("type")!=0: continue
        spans=[s for l in b["lines"] for s in l["spans"] if s["text"].strip()]
        if not spans: continue
        size=round(spans[0]["size"],1)
        if abs(size-12)>0.1: continue
        for l in b["lines"][:6]:
            print("line bbox",[round(x,1) for x in l["bbox"]])
            for s in l["spans"]:
                print("   span",[round(x,1) for x in s["bbox"]],round(s["size"],1),s["font"],repr(s["text"][:100]))
            n+=1
            if n>12: break
        if n>12: break
