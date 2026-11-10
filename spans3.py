import pymupdf
p=pymupdf.open("FLUTTER_BEFORE_ONE_LAST_14pt.pdf")[2]
for b in p.get_text("dict")["blocks"]:
    if b.get("type")!=0: continue
    if 330<b["bbox"][1]<410:
        print("BLOCK",[round(x,1) for x in b["bbox"]])
        for l in b["lines"]:
            print(" LINE",[round(x,1) for x in l["bbox"]])
            for s in l["spans"]:
                print("   ",repr(s["text"][:50]),s["size"],s["font"],[round(x,1) for x in s["bbox"]])
