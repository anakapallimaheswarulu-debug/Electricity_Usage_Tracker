import pymupdf
for fn in ["source_BEFORE_ONE_LAST.pdf","FLUTTER_BEFORE_ONE_LAST_14pt.pdf"]:
    d=pymupdf.open(fn); p=d[2]; print("="*40,fn)
    for b in sorted([b for b in p.get_text("dict")["blocks"] if b.get("type")==0],key=lambda b:b["bbox"][1]):
        spans=[s for l in b["lines"] for s in l["spans"] if s["text"].strip()]
        if not spans: continue
        print(f"y={b['bbox'][1]:.1f}-{b['bbox'][3]:.1f} x={b['bbox'][0]:.1f}-{b['bbox'][2]:.1f} sz={spans[0]['size']:.1f} {''.join(s['text'] for s in spans)[:70]!r}")
