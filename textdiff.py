import pymupdf, re, difflib
src=pymupdf.open("source_BEFORE_ONE_LAST.pdf"); out=pymupdf.open("FLUTTER_BEFORE_ONE_LAST_14pt.pdf")
def norm(t):
    t=t.replace("\xa0"," ").replace("\xad","")
    t=re.sub(r"[\u2028\u2029]"," ",t)
    return re.sub(r"[^A-Za-z0-9]+","",t)
for i in range(src.page_count):
    a=norm(src[i].get_text("text")); b=norm(out[i].get_text("text"))
    if a!=b:
        sm=difflib.SequenceMatcher(None,a,b,autojunk=False)
        print("="*60,"PAGE",i+1,"len",len(a),len(b),"ratio",round(sm.ratio(),4))
        for tag,i1,i2,j1,j2 in sm.get_opcodes():
            if tag!="equal":
                print(tag,repr(a[max(0,i1-40):i2+40]),"->",repr(b[max(0,j1-40):j2+40]))
                if i2-i1>200 or j2-j1>200: break
print("done")
