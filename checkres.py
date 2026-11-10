import pymupdf, os
src=pymupdf.open("source_BEFORE_ONE_LAST.pdf"); out=pymupdf.open("FLUTTER_BEFORE_ONE_LAST_14pt.pdf")
print("file sizes",os.path.getsize("source_BEFORE_ONE_LAST.pdf"),os.path.getsize("FLUTTER_BEFORE_ONE_LAST_14pt.pdf"))
for i in range(src.page_count):
    a=src[i].get_images(full=True); b=out[i].get_images(full=True)
    if len(a)!=len(b): print("IMG COUNT DIFF p",i+1,len(a),len(b))
print("images ok")
print("outline",len(out.get_toc()))
print("links src/out",sum(len(p.get_links()) for p in src),sum(len(p.get_links()) for p in out))
print("annots src/out",sum(len(list(p.annots())) for p in src),sum(len(list(p.annots())) for p in out))
