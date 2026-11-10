import zipfile, re
z=zipfile.ZipFile("source_conv.docx")
xml=z.read("word/document.xml").decode("utf-8")
print("len",len(xml))
for tag in ["w:p ","w:p>","w:txbxContent","w:sectPr","w:drawing","w:pict","w:tbl>","w:br w:type=\"page\"","w:lastRenderedPageBreak"]:
    print(tag, xml.count("<"+tag) if not tag.endswith(">") else xml.count("<"+tag))
print("styles:", z.read("word/styles.xml").decode("utf-8")[:800])
