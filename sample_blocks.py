import pymupdf
d=pymupdf.open("source_Updated_Fonts.pdf")
for pno in [2,3,4,5,7,16,20,33,44]:
    p=d[pno]
    print("="*80); print("PAGE",pno+1,"rect",p.rect)
    blocks=p.get_text("dict")["blocks"]
    for b in blocks:
        if b.get("type")!=0: 
            print(" [IMAGE block]", [round(x,1) for x in b["bbox"]]); continue
        tb=[]
        for l in b.get("lines",[]):
            s=l["spans"][0]
            tb.append((round(s["size"],1), s["font"], s["text"][:80]))
        print(" block", [round(x,1) for x in b["bbox"]], "lines",len(tb))
        for t in tb[:6]: print("   ",t)
