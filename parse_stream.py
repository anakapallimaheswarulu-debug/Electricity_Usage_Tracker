import pikepdf
from collections import Counter
pdf=pikepdf.open("source_BEFORE_ONE_LAST.pdf")
for pno in [2,3,5,13,48]:
    page=pdf.pages[pno]
    res=page.Resources
    fdict=res.get("/Font",{})
    names={}
    for k,v in fdict.items():
        try: names[str(k)]=str(v.get("/BaseFont"))
        except Exception as e: names[str(k)]=str(e)
    print("="*60); print("PAGE",pno+1,"fonts",names)
    try:
        cs=pikepdf.parse_content_stream(page)
    except Exception as e:
        print("parse err",e); continue
    cnt=Counter(); samples=[]
    curfont=None
    for ins in cs:
        op=str(ins.operator)
        if op=="Tf":
            curfont=(str(ins.operands[0]), float(ins.operands[1])); cnt[curfont]+=1
            if len(samples)<8: samples.append((op,[str(x) for x in ins.operands]))
        elif op in ("Tm","Td","TD","Tz","T*"):
            if len(samples)<14: samples.append((op,[str(x) for x in ins.operands]))
    print("Tf counts:",cnt.most_common(12))
    print("samples:",samples)
