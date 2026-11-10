import pymupdf
out=pymupdf.open("FLUTTER_BEFORE_ONE_LAST_14pt.pdf")
for pno in [3,6,14,32,35,39,50]:
    p=out[pno-1]; print("="*50,"PAGE",pno)
    for b in sorted([b for b in p.get_text("dict")["blocks"] if b.get("type")==0],key=lambda b:(b["bbox"][1],b["bbox"][0])):
        spans=[s for l in b["lines"] for s in l["spans"] if s["text"].strip()]
        if not spans: continue
        if b["bbox"][3]>730: continue
        print(f"y={b['bbox'][1]:.1f}-{b['bbox'][3]:.1f} x={b['bbox'][0]:.1f}-{b['bbox'][2]:.1f} n={len(b['lines'])} sz={spans[0]['size']:.1f} {''.join(s['text'] for s in spans)[:60]!r}")
