"""Descarga fotos de Wikimedia Commons y conserva identificación y licencia.

Las fotos son referencias de la especie, no fotografías de los ejemplares de
Huachipa. La app las incluye en assets para que no dependan de enlaces externos.
"""
import argparse
import concurrent.futures
import html
import io
import json
import re
import time
import threading
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps

ROOT=Path(__file__).resolve().parents[1]
CATALOG=ROOT/'docs/fauna/catalogo_huachipa.json'
PHOTOS=ROOT/'assets/images/fauna'
CACHE=ROOT/'output/research/wiki'
UA='SafariWorldEducationalPrototype/1.0 (local zoo visitor guide; Wikimedia attribution retained)'
RATE_LOCK=threading.Lock()
NEXT_INAT=0.0
for directory in (PHOTOS,CACHE): directory.mkdir(parents=True,exist_ok=True)

def get(url, binary=False):
    global NEXT_INAT
    last=None
    for attempt in range(5):
        try:
            if 'api.inaturalist.org' in url:
                with RATE_LOCK:
                    pause=max(0,NEXT_INAT-time.monotonic())
                    if pause: time.sleep(pause)
                    NEXT_INAT=time.monotonic()+0.85
            request=urllib.request.Request(url,headers={'User-Agent':UA,'Accept':'*/*'})
            with urllib.request.urlopen(request,timeout=45) as response:
                data=response.read()
            return data if binary else json.loads(data)
        except urllib.error.HTTPError as exc:
            if exc.code==404: return None
            last=exc
            time.sleep(min(3*(attempt+1),15))
        except Exception as exc:
            last=exc
            time.sleep(attempt+1)
    raise RuntimeError(f'{url}: {last}')

def api(**kwargs):
    return get('https://commons.wikimedia.org/w/api.php?'+urllib.parse.urlencode({'format':'json',**kwargs}))

def clean(s): return html.unescape(re.sub('<[^>]*>','',s or '')).strip()

def commons_name(url):
    match=re.search(r'/commons/(?:thumb/)?[a-f0-9]/[a-f0-9]{2}/([^/]+)',url)
    return urllib.parse.unquote(match[1]) if match else None

def summary(record):
    file=CACHE/(record['id']+'.json')
    if file.exists(): return json.loads(file.read_text(encoding='utf-8'))
    result={}
    for lang in ('es','en'):
        title=record.get('consulta_wiki',record['cientifico']).replace(' ','_')
        value=get(f'https://{lang}.wikipedia.org/api/rest_v1/page/summary/'+urllib.parse.quote(title,safe=''))
        if value and value.get('type')=='standard':
            result[lang]=value
        if lang=='es' and value:
            image=value.get('originalimage',value.get('thumbnail',{})).get('source','')
            if commons_name(image) and not re.search('range|distribution|map|iucn|status|logo',image,re.I): break
    file.write_text(json.dumps(result,ensure_ascii=False),encoding='utf-8')
    return result

def save(records): CATALOG.write_text(json.dumps(records,ensure_ascii=False,indent=2),encoding='utf-8')

def find_candidates(record,results):
    candidates=[]
    for lang,value in results.items():
        image=value.get('originalimage',value.get('thumbnail',{})).get('source','')
        name=commons_name(image)
        if name and not re.search('range|distribution|map|iucn|status|logo|skeleton',name,re.I):
            candidates.append(name)
    return list(dict.fromkeys(candidates))

def metadata(names):
    result={}
    names=list(dict.fromkeys(names))
    for start in range(0,len(names),20):
        payload=api(action='query',titles='|'.join('File:'+s for s in names[start:start+20]),
                    prop='imageinfo',iiprop='url|extmetadata|size',iiurlwidth=900)
        for page in payload.get('query',{}).get('pages',{}).values():
            if page.get('imageinfo'): result[page['title'][5:]]=page['imageinfo'][0]
    return result

def licensed(info):
    meta=info.get('extmetadata',{})
    license=clean(meta.get('LicenseShortName',{}).get('value',''))
    return bool(re.search(r'CC|public domain|dominio p[uú]blico|PD|attribution',license,re.I))

def search(record):
    query='filetype:bitmap '+record.get('consulta_wiki',record['cientifico'])
    payload=api(action='query',generator='search',gsrsearch=query,gsrnamespace=6,gsrlimit=8,
                prop='imageinfo',iiprop='url|extmetadata|size',iiurlwidth=900)
    pages=sorted(payload.get('query',{}).get('pages',{}).values(),key=lambda p:p.get('index',99))
    for page in pages:
        title=page.get('title','')
        if re.search('map|range|distribution|logo|skeleton|skull|egg|museum|specimen',title,re.I): continue
        info=page.get('imageinfo',[None])[0]
        if info and licensed(info) and info.get('width',0)>250 and info.get('height',0)>200:
            return info
    return None

def download(record,candidates,infos):
    file=PHOTOS/(record['id'].lower()+'.jpg')
    if file.exists() and record.get('foto',{}).get('licencia'):
        with Image.open(file) as image: image.verify()
        return record
    info=next((infos[n] for n in candidates if n in infos and licensed(infos[n])),None)
    if not info: info=search(record)
    if not info: raise RuntimeError(f"{record['nombre']}: no se encontró fotografía con licencia")
    url=info.get('thumburl',info['url'])
    data=get(url,True)
    image=Image.open(io.BytesIO(data))
    image=ImageOps.exif_transpose(image).convert('RGB')
    image.thumbnail((900,900),Image.Resampling.LANCZOS)
    if image.width<100 or image.height<100: raise ValueError('Imagen demasiado pequeña')
    image.save(file,'JPEG',quality=87,optimize=True)
    meta=info.get('extmetadata',{})
    record['foto']=dict(asset='assets/images/fauna/'+file.name,
        autor=clean(meta.get('Artist',{}).get('value','Autor acreditado en Wikimedia Commons')),
        licencia=clean(meta.get('LicenseShortName',{}).get('value','')),
        licencia_url=clean(meta.get('LicenseUrl',{}).get('value','')),
        fuente=info.get('descriptionurl',''),url_descarga=url,
        descripcion=clean(meta.get('ImageDescription',{}).get('value','')),
        ancho=image.width,alto=image.height,
        nota=record.get('nota_foto','') or 'Fotografía de referencia de la especie; no identifica a un ejemplar de Huachipa.')
    return record

def sheets(records):
    target=ROOT/'output/research/contactos'
    target.mkdir(parents=True,exist_ok=True)
    for start in range(0,len(records),30):
        canvas=Image.new('RGB',(1200,1020),'white')
        draw=ImageDraw.Draw(canvas)
        for offset,r in enumerate(records[start:start+30]):
            x=(offset%6)*200;y=(offset//6)*204
            file=ROOT/r.get('foto',{}).get('asset','missing')
            if file.is_file():
                image=ImageOps.fit(Image.open(file).convert('RGB'),(192,155))
                canvas.paste(image,(x+4,y+4))
            text=f"{r['id']} {r['nombre']}"[:32]
            draw.text((x+5,y+163),text,fill='black')
            draw.text((x+5,y+178),r['consulta_wiki'][:30],fill='black')
        path=target/f'fauna-{start//30+1}.jpg'
        canvas.save(path,quality=90)
        print(path,flush=True)

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--only',nargs='*')
    parser.add_argument('--sheets',action='store_true')
    parser.add_argument('--inat',action='store_true')
    args=parser.parse_args()
    records=json.loads(CATALOG.read_text(encoding='utf-8'))
    if args.sheets: sheets(records);return
    selected=[r for r in records if not args.only or r['id'] in args.only]
    if args.inat:
        from urllib.parse import urlencode
        def taxon_search(record):
            file=CACHE/(record['id']+'-inat.json')
            if file.exists(): return json.loads(file.read_text(encoding='utf-8'))
            query=record['consulta_wiki']
            if record['cientifico']=='Aratinga weddellii': query='Aratinga weddellii'
            parameters={'q':query,'per_page':8,'locale':'es'}
            if record['cientifico']=='Iguana iguana': parameters['rank']='species'
            data=get('https://api.inaturalist.org/v1/taxa?'+urlencode(parameters))
            matches=data.get('results',[])
            exact=next((t for t in matches if t['name'].lower()==query.lower()),None)
            exact=exact or next((t for t in matches if t.get('matched_term','').lower()==query.lower()),None)
            if not exact: raise RuntimeError(f'No se identificó inequívocamente {query}: {[t["name"] for t in matches]}')
            file.write_text(json.dumps(exact,ensure_ascii=False),encoding='utf-8')
            return exact
        found={}
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
            futures={pool.submit(taxon_search,r):r for r in selected}
            for i,f in enumerate(concurrent.futures.as_completed(futures),1):
                record=futures[f]
                try: found[record['id']]=f.result()
                except Exception as exc: print('TAXON ERROR',record['id'],str(exc),flush=True)
                if i%20==0: print(f'Taxones identificados {i}/{len(selected)}',flush=True)
        ids=list(dict.fromkeys(str(t['id']) for t in found.values()))
        full={}
        for cached in CACHE.glob('taxa-*.json'):
            data=json.loads(cached.read_text(encoding='utf-8'))
            full.update({t['id']:t for t in data.get('results',[])})
        pending_ids=[identifier for identifier in ids if int(identifier) not in full]
        for start in range(0,len(pending_ids),15):
            file=CACHE/('taxa-'+str(start//15)+'.json')
            # El nombre de caché incorpora el conjunto de IDs para evitar datos de otra selección.
            file=CACHE/('taxa-'+str(pending_ids[start])+'.json')
            data=get('https://api.inaturalist.org/v1/taxa/'+','.join(pending_ids[start:start+15])+'?locale=es')
            file.write_text(json.dumps(data,ensure_ascii=False),encoding='utf-8')
            full.update({t['id']:t for t in data.get('results',[])})
            print(f'Perfiles biológicos {min(start+15,len(ids))}/{len(ids)}',flush=True)
        def photo_inat(record):
            taxon=full.get(found.get(record['id'],{}).get('id'),{})
            file=PHOTOS/(record['id'].lower()+'.jpg')
            if taxon:
                record['taxon_id']=taxon['id']
                record['taxon_nombre']=taxon['name']
                record['wiki_resumen']=clean(taxon.get('wikipedia_summary',''))
                record['fuente_biologia']='https://www.inaturalist.org/taxa/'+str(taxon['id'])
                record['fuente_wikipedia']=taxon.get('wikipedia_url','')
                record['estado_conservacion']=taxon.get('conservation_status',{})
            if file.exists() and record.get('foto',{}).get('licencia'):
                with Image.open(file) as image: image.verify()
                return
            photos=[p['photo'] for p in taxon.get('taxon_photos',[]) if p.get('photo')]
            if not photos and found.get(record['id'],{}).get('default_photo'):
                photos=[found[record['id']]['default_photo']]
            photo=next((p for p in photos if p.get('license_code') in ('cc0','cc-by','cc-by-sa')),None)
            if not photo and taxon.get('id'):
                data=get('https://api.inaturalist.org/v1/observations?'+urlencode({
                    'taxon_id':taxon['id'],'photo_license':'cc0,cc-by,cc-by-sa',
                    'quality_grade':'research','per_page':4,'order_by':'votes','photos':'true'}))
                for observation in data.get('results',[]):
                    photo=next((p for p in observation.get('photos',[])
                                if p.get('license_code') in ('cc0','cc-by','cc-by-sa')),None)
                    if photo:
                        photo['large_url']=photo['url'].replace('/square.','/large.')
                        break
                if not photo:
                    # Las especies exóticas de cautiverio pueden no tener registros
                    # silvestres de grado investigación. La identidad se revisa en
                    # la hoja de contacto antes de integrar la fotografía.
                    data=get('https://api.inaturalist.org/v1/observations?'+urlencode({
                        'taxon_id':taxon['id'],'photo_license':'cc0,cc-by,cc-by-sa',
                        'per_page':8,'photos':'true'}))
                    for observation in data.get('results',[]):
                        photo=next((p for p in observation.get('photos',[])
                                    if p.get('license_code') in ('cc0','cc-by','cc-by-sa')),None)
                        if photo:
                            photo['large_url']=photo['url'].replace('/square.','/large.')
                            break
            if not photo:
                return download(record,[],{})
            url=photo.get('large_url') or photo['medium_url']
            image=ImageOps.exif_transpose(Image.open(io.BytesIO(get(url,True)))).convert('RGB')
            image.thumbnail((900,900),Image.Resampling.LANCZOS)
            if min(image.size)<100: raise ValueError('Imagen demasiado pequeña')
            image.save(file,'JPEG',quality=87,optimize=True)
            code=photo['license_code']
            record['foto']=dict(asset='assets/images/fauna/'+file.name,
                autor=photo.get('attribution_name') or photo.get('attribution','Autor indicado en iNaturalist'),
                licencia={'cc0':'CC0','cc-by':'CC BY','cc-by-sa':'CC BY-SA'}[code],
                licencia_url='https://creativecommons.org/'+('publicdomain/zero/1.0/' if code=='cc0' else 'licenses/'+code[3:]+'/4.0/'),
                fuente='https://www.inaturalist.org/photos/'+str(photo['id']),url_descarga=url,
                descripcion=taxon.get('name',record['cientifico']),ancho=image.width,alto=image.height,
                nota=record.get('nota_foto','') or 'Fotografía de referencia de la especie; no identifica a un ejemplar de Huachipa.')
        errors=[]
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
            futures={pool.submit(photo_inat,r):r for r in selected}
            for i,f in enumerate(concurrent.futures.as_completed(futures),1):
                record=futures[f]
                try: f.result()
                except Exception as exc:
                    errors.append(record['id']);print('FOTO ERROR',record['id'],str(exc)[:220],flush=True)
                if i%10==0 or i==len(selected):
                    save(records);print(f'Fotografías {i}/{len(selected)}; pendientes {len(errors)}',flush=True)
        save(records)
        print('Pendientes:',','.join(errors) or 'ninguno',flush=True)
        if errors: raise SystemExit(1)
        return
    results={}
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        futures={pool.submit(summary,r):r for r in selected}
        for i,f in enumerate(concurrent.futures.as_completed(futures),1):
            r=futures[f]
            try:
                value=f.result();results[r['id']]=value
                spanish=value.get('es',{})
                r['wiki_resumen']=spanish.get('extract','')
                primary=spanish or value.get('en',{})
                r['fuente_biologia']=primary.get('content_urls',{}).get('desktop',{}).get('page','')
                r['revision_biologia']=primary.get('revision','')
            except Exception as exc: print('RESUMEN ERROR',r['id'],str(exc)[:180],flush=True)
            if i%15==0: print(f'Resumenes {i}/{len(selected)}',flush=True)
    candidates={r['id']:find_candidates(r,results.get(r['id'],{})) for r in selected}
    infos=metadata([n for ns in candidates.values() for n in ns])
    save(records)
    failures=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        futures={pool.submit(download,r,candidates[r['id']],infos):r for r in selected}
        for i,f in enumerate(concurrent.futures.as_completed(futures),1):
            r=futures[f]
            try: f.result()
            except Exception as exc:
                failures.append(r['id']);print('FOTO ERROR',r['id'],str(exc)[:220],flush=True)
            if i%10==0 or i==len(selected):
                save(records);print(f'Fotografias {i}/{len(selected)}; pendientes {len(failures)}',flush=True)
    save(records)
    print('Pendientes:',','.join(failures) or 'ninguno',flush=True)
    if failures: raise SystemExit(1)

if __name__=='__main__': main()
