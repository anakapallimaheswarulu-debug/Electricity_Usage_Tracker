import docx, collections
d=docx.Document("source_conv.docx")
print("paragraphs", len(d.paragraphs), "tables", len(d.tables), "inline_shapes", len(d.inline_shapes), "sections", len(d.sections))
fonts=collections.Counter(); sizes=collections.Counter()
for p in d.paragraphs:
    st=p.style.name if p.style else None
    if p.text.strip():
        fonts[(st, p.runs[0].font.name if p.runs else None)]+=len(p.text)
        for r in p.runs:
            if r.text.strip(): sizes[(r.font.size.pt if r.font.size else None, st, r.bold, r.italic)]+=len(r.text)
print("styles/fonts top:")
for k,v in fonts.most_common(20): print(" ",k,v)
print("sizes top:")
for k,v in sizes.most_common(25): print(" ",k,v)
