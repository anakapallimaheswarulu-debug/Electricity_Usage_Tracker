import pikepdf, pymupdf, collections
src="source_BEFORE_ONE_LAST.pdf"; out="test_edit.pdf"
pdf=pikepdf.open(src)
pno=2
page=pdf.pages[pno]
fdict=page.Resources.get("/Font",{})
names={str(k):str(v.get("/BaseFont")) for k,v in fdict.items()}
cs=pikepdf.parse_content_stream(page)
new=[]
for ins in cs:
    op=str(ins.operator)
    if op=="Tf":
        f=str(ins.operands[0]); s=float(ins.operands[1]); b=names.get(f,"")
        news=s; tz=100.0
        if abs(s-12)<0.01 and "Times" in b:
            news=14.0; tz=12.0/14.0*100.0
        elif abs(s-14)<0.01 and "Bold" in b:
            news=16.0; tz=14.0/16.0*100.0
        new.append(pikepdf.ContentStreamInstruction([ins.operands[0], news], pikepdf.Operator("Tf")))
        new.append(pikepdf.ContentStreamInstruction([round(tz,4)], pikepdf.Operator("Tz")))
    else:
        new.append(ins)
data=pikepdf.unparse_content_stream(new)
page.Contents = pdf.make_stream(data)
pdf.save(out, linearize=False)
d=pymupdf.open(out); p=d[2]
print("saved. page size",p.rect,"pages",d.page_count)
sizes=collections.Counter()
for b in p.get_text("dict")["blocks"]:
    for l in b.get("lines",[]):
        for s in l["spans"]:
            if s["text"].strip(): sizes[(round(s["size"],1),s["font"])]+=len(s["text"])
print(sizes.most_common(10))
for b in p.get_text("dict")["blocks"][:8]:
    if b.get("type")!=0: continue
    print("bbox",[round(x,1) for x in b["bbox"]], "line rights",[round(l["bbox"][2],1) for l in b.get("lines",[])][:4], "line tops",[round(l["bbox"][1],1) for l in b.get("lines",[])][:4])
