import pymupdf, collections
for fn in ["source_Updated_Fonts.pdf","source_BEFORE_ONE_LAST.pdf"]:
    d=pymupdf.open(fn)
    print("="*70); print(fn, "pages:", d.page_count)
    for i,p in enumerate(d):
        txt=p.get_text("dict")
        sizes=collections.Counter(); fonts=collections.Counter()
        for b in txt["blocks"]:
            for l in b.get("lines",[]):
                for s in l["spans"]:
                    if s["text"].strip():
                        sizes[round(s["size"],1)]+=len(s["text"])
                        fonts[s["font"]]+=len(s["text"])
        imgs=len(p.get_images(full=True))
        drawings=len(p.get_drawings())
        print(f"p{i+1}: imgs={imgs} draws={drawings} sizes={sorted(sizes.items(), key=lambda x:-x[1])[:6]}")
    print("fonts:", fonts.most_common(10))
