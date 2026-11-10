import pymupdf, collections
src=pymupdf.open("source_BEFORE_ONE_LAST.pdf"); out=pymupdf.open("FLUTTER_BEFORE_ONE_LAST_14pt.pdf")
print("pages",src.page_count,out.page_count,"size",out.metadata)
for pno in [3,6,12,32,35,39,50]:
    p=out[pno-1]; sizes=collections.Counter(); maxx=0; maxy=0; styles=collections.Counter()
    for b in p.get_text("dict")["blocks"]:
        if b.get("type")!=0: continue
        for l in b.get("lines",[]):
            for s in l["spans"]:
                if not s["text"].strip(): continue
                if s["bbox"][3]>730: continue
                sizes[round(s["size"],2)]+=len(s["text"])
                maxx=max(maxx,s["bbox"][2]); maxy=max(maxy,s["bbox"][3])
                styles[(round(s["size"],1),s["font"])]+=len(s["text"])
    print("="*30,"p",pno,"maxx",round(maxx,1),"maxy",round(maxy,1),"sizes",sizes.most_common())
    print("  styles",styles.most_common(8))
