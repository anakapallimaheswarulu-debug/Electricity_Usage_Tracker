import pikepdf
p=pikepdf.open("FLUTTER_BEFORE_ONE_LAST_14pt.pdf")
print("pages",len(p.pages))
print("check",p.check())
print("pdf_version",p.pdf_version)
