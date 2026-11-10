import re, math, sys
import pymupdf

SRC="source_BEFORE_ONE_LAST.pdf"
OUT="FLUTTER_BEFORE_ONE_LAST_14pt.pdf"
FONT_REG=r"C:\Windows\Fonts\times.ttf"
FONT_BOLD=r"C:\Windows\Fonts\timesbd.ttf"
IMG_PAGES={1,8,9,10,15,17,18,19,20,21,23,25,29,30,34,36,45,46,47,48}
ELIGIBLE=[3,4,5,6,7,11,12,13,14,16,22,24,26,27,28,31,32,33,35,37,38,39,40,41,42,43,44,49,50,51]
LEFT=61.2
RIGHT=557.3
BODY_PITCH=18.0
HEAD_PITCH=20.0

font_reg=pymupdf.Font(fontfile=FONT_REG)
font_bold=pymupdf.Font(fontfile=FONT_BOLD)

def mode_style(b):
    cnt={}
    for l in b.get("lines",[]):
        for s in l.get("spans",[]):
            t=s.get("text","")
            if not t.strip(): continue
            k=(s["font"],round(s["size"],1),s["color"],bool(s["flags"]&16))
            cnt[k]=cnt.get(k,0)+len(t)
    if not cnt: return None
    return max(cnt.items(), key=lambda kv: kv[1])[0]

def kind_of(b,style):
    font,size,color,bold=style
    if size<=10.05 or "Consol" in font or "Mono" in font:
        return "code"
    if abs(size-14)<0.12 and bold:
        return "head14"
    if abs(size-16)<0.12 and bold:
        return "head16"
    if abs(size-12)<0.12:
        return "body"
    if abs(size-11)<0.15 or abs(size-11.04)<0.15:
        return "other"
    return "other"

def split_lines(b):
    out=[]
    for l in b.get("lines",[]):
        t="".join(s.get("text","") for s in l.get("spans",[]))
        if t.strip(): out.append(t)
    return out

def clean_line(raw):
    t=raw.replace("\xa0"," ")
    soft=t.endswith("\xad")
    if soft: t=t[:-1]
    t=t.replace("\xad","-")
    return t.strip(), soft

def join_para(raw_lines):
    out=""
    prev_soft=False
    for raw in raw_lines:
        t,soft=clean_line(raw)
        if not t: continue
        if not out: out=t
        elif prev_soft or out.endswith("-"): out+=t
        else: out+=" "+t
        prev_soft=soft
    return out

def marker_re():
    return re.compile(r"^(•|\d+\.)\s*")

def parse_items(raw_lines):
    mre=marker_re()
    items=[]
    for raw in raw_lines:
        t,soft=clean_line(raw)
        if not t: continue
        m=mre.match(t)
        if m:
            prefix=m.group(0)
            if not prefix.endswith(" "): prefix+=" "
            content=t[m.end():].strip()
            items.append({"prefix":prefix,"content":content,"soft":soft})
        elif items:
            if items[-1]["soft"] or items[-1]["content"].endswith("-"):
                items[-1]["content"]+=t
            else:
                items[-1]["content"]+=" "+t
            items[-1]["soft"]=soft
        else:
            items.append({"prefix":"","content":t,"soft":soft})
    return items

def wrap(text,font,size,width):
    text=text.strip()
    if not text: return [""]
    words=text.split(" ")
    lines=[]; cur=""
    for w in words:
        if not w: continue
        trial=w if not cur else cur+" "+w
        if font.text_length(trial,size)<=width or not cur:
            cur=trial
        else:
            lines.append(cur); cur=w
    if cur: lines.append(cur)
    return lines

def text_layout(b,kind):
    raw=split_lines(b)
    size=14.0
    font=font_reg
    if kind=="head14": size=16.0; font=font_bold
    elif kind=="head16": size=16.0; font=font_bold
    elif kind=="body": size=14.0; font=font_reg
    pitch=BODY_PITCH if size==14.0 else HEAD_PITCH
    x0=b["bbox"][0]
    mre=marker_re()
    first=clean_line(raw[0])[0] if raw else ""
    is_list=bool(mre.match(first))
    draw=[]
    if is_list:
        items=parse_items(raw)
        line_no=0
        for it in items:
            prefix=it["prefix"]
            content=it["content"]
            pw=font.text_length(prefix,size) if prefix else 0.0
            tx=x0+pw
            w=RIGHT-tx
            ls=wrap(content,font,size,w)
            for j,line in enumerate(ls):
                draw.append((tx,line,line_no,prefix if j==0 else ""))
                line_no+=1
    else:
        text=join_para(raw)
        ls=wrap(text,font,size,RIGHT-x0)
        for j,line in enumerate(ls):
            draw.append((x0,line,j,""))
    nlines=len(draw)
    height=(font.ascender-font.descender)*size+(nlines-1)*pitch
    color=0
    for l in b.get("lines",[]):
        for s in l.get("spans",[]):
            if s["text"].strip():
                color=s["color"]; break
        if color: break
    return {"size":size,"font":font,"pitch":pitch,"draw":draw,"height":height,"color":color,"x0":x0}

def union_rect(a,b):
    if a is None: return pymupdf.Rect(b)
    r=pymupdf.Rect(a); r|=b; return r

def build_page(page, pno):
    infos=[]
    for b in page.get_text("dict")["blocks"]:
        if b.get("type")!=0: continue
        if b["bbox"][3]>730: continue
        style=mode_style(b)
        if not style: continue
        kind=kind_of(b,style)
        infos.append({"block":b,"kind":kind,"style":style,"bbox":pymupdf.Rect(b["bbox"])})
    drawings=[dr for dr in page.get_drawings() if dr["rect"].x0>40 and dr["rect"].x1<580 and dr["rect"].y0>40 and dr["rect"].y1<730]
    consumed=set()
    elements=[]

    others=sorted([x for x in infos if x["kind"]=="other"], key=lambda x:(x["bbox"].y0,x["bbox"].x0))
    groups=[]
    for x in others:
        if groups and x["bbox"].y0-groups[-1][-1]["bbox"].y1<30:
            groups[-1].append(x)
        else:
            groups.append([x])
    for g in groups:
        region=union_rect(None,g[0]["bbox"])
        for x in g[1:]: region=union_rect(region,x["bbox"])
        table=(len(g)>=2)
        if not table:
            for dr in drawings:
                r=dr["rect"]
                if r.x0<=region.x0+2 and r.x1>=region.x1-2 and r.y0<=region.y0+2 and r.y1>=region.y1-2 and r.width>400 and r.height>20:
                    table=True; break
        if not table:
            continue
        for dr in drawings:
            r=dr["rect"]
            if r.y1<region.y0-4 or r.y0>region.y1+4: continue
            if not (r.width>400 or r.height>20): continue
            region=union_rect(region,r)
        region=pymupdf.Rect(region.x0-0.8,region.y0-0.8,region.x1+0.8,region.y1+0.8)
        for x in g: consumed.add(id(x))
        elements.append({"type":"table","bbox":region,"orig_top":region.y0,"orig_bottom":region.y1,"height":region.height,"redraw":True})

    code_infos=[x for x in infos if x["kind"]=="code" and id(x) not in consumed]
    gray=[]
    for dr in drawings:
        f=dr.get("fill")
        if f is None: continue
        mx=max(f); mn=min(f)
        if mx>0.985 or mx-mn>0.02: continue
        r=dr["rect"]
        if r.width>300 and r.height>10:
            gray.append(r)
    assigned={}
    for ci in code_infos:
        bb=ci["bbox"]
        cands=[]
        for r in gray:
            if r.x0-1<=bb.x0 and r.y0-1<=bb.y0 and r.x1+1>=bb.x1 and r.y1+1>=bb.y1:
                cnt=sum(1 for cj in code_infos if r.x0-1<=cj["bbox"].x0 and r.y0-1<=cj["bbox"].y0 and r.x1+1>=cj["bbox"].x1 and r.y1+1>=cj["bbox"].y1)
                cands.append((cnt,r.get_area(),r))
        if cands:
            cands.sort(key=lambda t:(t[0],t[1]), reverse=True)
            r=cands[0][2]
            key=(round(r.x0,1),round(r.y0,1),round(r.x1,1),round(r.y1,1))
            assigned.setdefault(key,{"rect":pymupdf.Rect(r),"infos":[]})["infos"].append(ci)
        else:
            r=pymupdf.Rect(bb.x0-6,bb.y0-6,bb.x1+6,bb.y1+6)
            key=("own",round(bb.y0,1),round(bb.x0,1))
            assigned.setdefault(key,{"rect":r,"infos":[]})["infos"].append(ci)
    for key,g in assigned.items():
        r=g["rect"]
        for ci in g["infos"]: consumed.add(id(ci))
        elements.append({"type":"code","bbox":r,"orig_top":r.y0,"orig_bottom":r.y1,"height":r.height,"redraw":True})

    for x in infos:
        if id(x) in consumed: continue
        if x["kind"] in ("body","head14","head16"):
            lay=text_layout(x["block"],x["kind"])
            elements.append({"type":"text","bbox":x["bbox"],"orig_top":x["bbox"].y0,"orig_bottom":x["bbox"].y1,"height":lay["height"],"layout":lay,"redraw":False})
        elif x["kind"]=="other":
            elements.append({"type":"fixedtext","bbox":x["bbox"],"orig_top":x["bbox"].y0,"orig_bottom":x["bbox"].y1,"height":x["bbox"].height,"redraw":False})

    elements.sort(key=lambda e:(round(e["orig_top"],2),e["bbox"].x0))
    prev_bottom=None; prev_orig_bottom=None
    for e in elements:
        if prev_bottom is None:
            target=e["orig_top"]
        else:
            gap=max(0.0,e["orig_top"]-prev_orig_bottom)
            target=max(e["orig_top"],prev_bottom+gap)
        e["target_top"]=target
        e["target_bottom"]=target+e["height"]
        prev_bottom=e["target_bottom"]
        prev_orig_bottom=e["orig_bottom"]
    return elements

def main():
    dry="--dry" in sys.argv
    src=pymupdf.open(SRC)
    reports={}
    for pno in ELIGIBLE:
        elements=build_page(src[pno-1],pno)
        bottom=max(e["target_bottom"] for e in elements) if elements else 0
        origbottom=max(e["orig_bottom"] for e in elements) if elements else 0
        kinds={}
        for e in elements: kinds[e["type"]]=kinds.get(e["type"],0)+1
        reports[pno]=(bottom,origbottom,kinds,elements)
        print(f"p{pno:02d} bottom {origbottom:.1f}->{bottom:.1f} free {726-bottom:.1f} elements {kinds}")
        for e in elements:
            if e["type"]=="text":
                lay=e["layout"]
                if len(lay["draw"])>0 and e["target_bottom"]>726.01:
                    print("  OVERFLOW TEXT",e["bbox"],[round(x,1) for x in [e["target_top"],e["target_bottom"]]],lay["draw"][0][1][:40])
    if dry:
        return
    doc=pymupdf.open(SRC)
    for pno in ELIGIBLE:
        elements=reports[pno][3]
        page=doc[pno-1]
        red=[]
        for e in elements:
            if e["type"]=="text":
                red.append((pymupdf.Rect(e["bbox"].x0-0.6,e["bbox"].y0-0.6,e["bbox"].x1+0.6,e["bbox"].y1+0.6),"text",e))
            elif e["type"]=="code":
                red.append((pymupdf.Rect(e["bbox"].x0-0.6,e["bbox"].y0-0.6,e["bbox"].x1+0.6,e["bbox"].y1+0.6),"code",e))
            elif e["type"]=="table" and abs(e["target_top"]-e["orig_top"])>0.01:
                red.append((pymupdf.Rect(e["bbox"].x0-0.6,e["bbox"].y0-0.6,e["bbox"].x1+0.6,e["bbox"].y1+0.6),"table",e))
            elif e["type"]=="fixedtext" and abs(e["target_top"]-e["orig_top"])>0.01:
                red.append((pymupdf.Rect(e["bbox"].x0-0.6,e["bbox"].y0-0.6,e["bbox"].x1+0.6,e["bbox"].y1+0.6),"fixedtext",e))
        for r,typ,e in red:
            page.add_redact_annot(r,fill=(1,1,1))
        if red:
            page.apply_redactions(images=pymupdf.PDF_REDACT_IMAGE_NONE,graphics=pymupdf.PDF_REDACT_LINE_ART_REMOVE_IF_TOUCHED,text=pymupdf.PDF_REDACT_TEXT_REMOVE)
        for e in elements:
            if e["type"]=="code":
                r=e["bbox"]
                ext=pymupdf.Rect(r.x0-3,e["target_top"]-3,r.x1+3,e["target_bottom"]+3)
                sh=page.new_shape(); sh.draw_rect(ext); sh.finish(fill=(0.949,0.949,0.949),color=None); sh.commit()
                tr=pymupdf.Rect(r.x0,e["target_top"],r.x1,e["target_bottom"])
                page.show_pdf_page(tr,src,pno-1,clip=r)
            elif e["type"]=="table" and abs(e["target_top"]-e["orig_top"])>0.01:
                r=e["bbox"]
                tr=pymupdf.Rect(r.x0,e["target_top"],r.x1,e["target_bottom"])
                page.show_pdf_page(tr,src,pno-1,clip=r)
            elif e["type"]=="fixedtext" and abs(e["target_top"]-e["orig_top"])>0.01:
                r=e["bbox"]
                tr=pymupdf.Rect(r.x0,e["target_top"],r.x1,e["target_bottom"])
                page.show_pdf_page(tr,src,pno-1,clip=r)
        page.insert_font(fontname="TNRX",fontfile=FONT_REG)
        page.insert_font(fontname="TNRBX",fontfile=FONT_BOLD)
        for e in elements:
            if e["type"]!="text": continue
            lay=e["layout"]; size=lay["size"]; font=lay["font"]; pitch=lay["pitch"]; color=pymupdf.sRGB_to_pdf(lay["color"])
            alias="TNRBX" if font is font_bold else "TNRX"
            for tx,line,idx,prefix in lay["draw"]:
                top=e["target_top"]+idx*pitch
                baseline=top+font.ascender*size
                if prefix:
                    page.insert_text((lay["x0"],baseline),prefix,fontname=alias,fontsize=size,color=color,render_mode=0)
                page.insert_text((tx,baseline),line,fontname=alias,fontsize=size,color=color,render_mode=0)
    doc.save(OUT,garbage=3,deflate=True)
    print("SAVED",OUT)

if __name__=="__main__":
    main()
