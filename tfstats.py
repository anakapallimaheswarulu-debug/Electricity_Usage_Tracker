import pikepdf, pymupdf
from collections import Counter, defaultdict
pdf=pikepdf.open("source_BEFORE_ONE_LAST.pdf")
mp=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
imgpages={i+1 for i,p in enumerate(mp) if p.get_images(full=True)}
print("image pages:",sorted(imgpages))
elig=[i+1 for i in range(len(pdf.pages)) if (i+1) not in imgpages and i>1]
print("eligible:",elig)
cnt=Counter(); bypage=defaultdict(Counter)
for pno in elig:
    page=pdf.pages[pno-1]
    fdict=page.Resources.get("/Font",{}) if page.Resources else {}
    names={str(k):str(v.get("/BaseFont")) for k,v in fdict.items()} if fdict else {}
    for ins in pikepdf.parse_content_stream(page):
        if str(ins.operator)=="Tf":
            f=str(ins.operands[0]); s=float(ins.operands[1]); b=names.get(f,"?")
            cnt[(f,b,s)]+=1; bypage[pno][(f,b,s)]+=1
for k,v in cnt.most_common(): print(k,v)
print("pages with 12 non-tnr:")
for p,c in bypage.items():
    for (f,b,s),n in c.items():
        if abs(s-12)<0.01 and "Regular" not in b: print(p,f,b,s,n)
