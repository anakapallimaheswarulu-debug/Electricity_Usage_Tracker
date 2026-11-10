import pymupdf
d=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
for pno in [3,14,50]:
    p=d[pno-1]; print("="*40,"PAGE",pno)
    for b in p.get_text("dict")["blocks"]:
        if b.get("type")!=0: continue
        if b["bbox"][3]>730: continue
        txt="".join(s["text"] for l in b["lines"] for s in l["spans"])
        if pno==3 and not (63<b["bbox"][1]<270): continue
        if pno==14 and not (150<b["bbox"][1]<360): continue
        if pno==50: pass
        print("BLOCK", [round(x,1) for x in b["bbox"]], repr(txt[:60]))
        for l in b["lines"][:4]:
            print("   LINE", [round(x,1) for x in l["bbox"]], [(s["text"][:25],round(s["bbox"][0],1),round(s["bbox"][2],1)) for s in l["spans"]])
