import pymupdf
for fn in ["source_Updated_Fonts.pdf","source_BEFORE_ONE_LAST.pdf"]:
    d=pymupdf.open(fn); print("="*60); print(fn); print(d.metadata)
    print("fonts:", d.get_page_fonts(2))
    print("toc:", d.get_toc()[:5])
