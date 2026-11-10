import pymupdf
for fn in ["source_Updated_Fonts.pdf","source_BEFORE_ONE_LAST.pdf"]:
    d=pymupdf.open(fn)
    words=sum(len(p.get_text("words")) for p in d)
    chars=sum(len(p.get_text()) for p in d)
    print(fn, "words", words, "chars", chars)
    print(" first 300:", repr(d[0].get_text()[:300]))
    print(" page2 300:", repr(d[1].get_text()[:300]))
