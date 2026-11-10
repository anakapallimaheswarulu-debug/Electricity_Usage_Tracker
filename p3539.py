import pymupdf
d=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
for pno in [35,39]:
    p=d[pno-1]; print("="*30,"PAGE",pno)
    for b in p.get_text("dict")["blocks"]:
        if b.get("type")!=0: continue
        spans=[s for l in b["lines"] for s in l["spans"] if s["text"].strip()]
        if not spans: continue
        print(f"y={b['bbox'][1]:.1f}-{b['bbox'][3]:.1f} sz={spans[0]['size']:.1f} font={spans[0]['font']} text={''.join(s['text'] for s in spans)[:70]!r}")
