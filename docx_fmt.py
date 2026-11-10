import docx, collections
d=docx.Document("source_conv.docx")
sizes=collections.Counter(); fonts=collections.Counter(); combos=collections.Counter()
for p in d.paragraphs:
    for r in p.runs:
        t=r.text.strip()
        if not t: continue
        sz=(r.font.size.pt if r.font.size else None)
        sizes[sz]+=len(t); fonts[r.font.name]+=len(t)
        combos[(sz,r.font.name,bool(r.bold),bool(r.italic))]+=len(t)
print("sizes:", sizes.most_common(15))
print("fonts:", fonts.most_common(10))
print("combos:")
for k,v in combos.most_common(25): print(" ",k,v)
print("sections page sizes/margins:")
for s in d.sections[:3]:
    print(s.page_width,s.page_height,s.left_margin,s.right_margin,s.top_margin,s.bottom_margin)
