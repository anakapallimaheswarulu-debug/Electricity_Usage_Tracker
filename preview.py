import pymupdf
d=pymupdf.open("source_BEFORE_ONE_LAST.pdf")
for pno in [35,39,27,50,5]:
    p=d[pno-1]
    pix=p.get_pixmap(dpi=110, colorspace=pymupdf.csRGB)
    pix.save(f"preview_p{pno}.png")
    print(pno,pix.width,pix.height)
