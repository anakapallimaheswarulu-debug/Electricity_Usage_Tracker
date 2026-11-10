import docx, pymupdf, difflib, re
d=docx.Document("source_conv.docx")
dt="\n".join(p.text for p in d.paragraphs)
def norm(s):
    s=s.replace("\xa0"," ").replace("\xad","").replace("\u2019","'")
    return re.findall(r"\S+", s)
for fn in ["source_BEFORE_ONE_LAST.pdf","source_Updated_Fonts.pdf"]:
    pdf=pymupdf.open(fn); pt="\n".join(p.get_text() for p in pdf)
    a=norm(pt); b=norm(dt)
    sm=difflib.SequenceMatcher(None,a,b,autojunk=False)
    print("="*60); print(fn, "pdfwords",len(a),"docxwords",len(b),"ratio",round(sm.ratio(),4))
    for tag,i1,i2,j1,j2 in sm.get_opcodes():
        if tag!='equal':
            print(tag, " ".join(a[i1:i2])[:120], "=>", " ".join(b[j1:j2])[:120])
            if tag=='replace' and i2-i1>10: break
