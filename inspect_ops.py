import pikepdf, pymupdf
from collections import Counter
pdf=pikepdf.open("source_BEFORE_ONE_LAST.pdf")
d=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
ops=Counter(); per_page={}
for i,page in enumerate(pdf.pages):
    try:
        cs=pikepdf.parse_content_stream(page)
    except Exception as e:
        print("parse fail page",i+1,e); continue
    c=Counter(str(ins.operator) for ins in cs)
    ops.update(c); per_page[i+1]=c
print("ops overall:",ops.most_common())
for op in ["Tz","Tc","Tw","TJ","Tj","'",'"',"BI","Do"]:
    pages=[p for p,c in per_page.items() if c.get(op)]
    print(op,"pages:",pages[:60],"count",sum(c.get(op,0) for c in per_page.values()))
print("multistream pages:", [(i+1,len(pdf.pages[i].obj.get('/Contents',[]))) for i in range(len(pdf.pages)) if not isinstance(pdf.pages[i].obj.get('/Contents'),pikepdf.Object) or (isinstance(pdf.pages[i].obj.get('/Contents'),pikepdf.Array) and len(pdf.pages[i].obj.get('/Contents'))>1)][:10])
