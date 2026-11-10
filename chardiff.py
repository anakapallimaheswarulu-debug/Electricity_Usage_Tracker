import pymupdf, re, collections
src=pymupdf.open("source_BEFORE_ONE_LAST.pdf"); out=pymupdf.open("FLUTTER_BEFORE_ONE_LAST_14pt.pdf")
def norm(t):
    t=t.replace("\xa0"," ").replace("\xad","")
    return re.sub(r"[^A-Za-z0-9]+","",t)
for i in range(src.page_count):
    a=norm(src[i].get_text("text")); b=norm(out[i].get_text("text"))
    ca=collections.Counter(a); cb=collections.Counter(b)
    if ca!=cb or len(a)!=len(b):
        print("PAGE",i+1,"len",len(a),len(b),"char_counter_equal",ca==cb)
        for ch,n in (ca-cb).items(): print("  missing",repr(ch),n)
        for ch,n in (cb-ca).items(): print("  extra",repr(ch),n)
print("done")
