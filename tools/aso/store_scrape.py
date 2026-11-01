import json, re, html, sys, time, urllib.request, urllib.parse

UA = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36",
      "Accept-Language": "en-IN,en;q=0.9"}

import subprocess
def get(url):
    r = subprocess.run(["curl","-sL","--max-time","40","-A",UA["User-Agent"],"-H","Accept-Language: en-IN,en;q=0.9",url],capture_output=True)
    if r.returncode != 0: raise RuntimeError(f"curl exit {r.returncode}")
    return r.stdout.decode("utf-8","replace")

def strip(s):
    s = re.sub(r"<br\s*/?>", "\n", s)
    s = re.sub(r"<[^>]+>", "", s)
    return html.unescape(s).strip()

# ---------- iTunes ----------
def itunes_search(term, country="in", limit=12):
    url = "https://itunes.apple.com/search?" + urllib.parse.urlencode({"term": term, "country": country, "entity": "software", "limit": limit})
    data = json.loads(get(url))
    rows = []
    for r in data.get("results", []):
        rows.append({
            "id": r.get("trackId"), "name": r.get("trackName"), "seller": r.get("sellerName"),
            "genre": r.get("primaryGenreName"), "genres": r.get("genres"),
            "rating": r.get("averageUserRating"), "ratings": r.get("userRatingCount"),
            "released": (r.get("releaseDate") or "")[:10], "updated": (r.get("currentVersionReleaseDate") or "")[:10],
            "price": r.get("formattedPrice"), "langs": r.get("languageCodesISO2A"),
            "desc": (r.get("description") or "")[:350].replace("\n", " "),
        })
    return rows

def itunes_lookup(app_id, country="in"):
    data = json.loads(get(f"https://itunes.apple.com/lookup?id={app_id}&country={country}"))
    out = []
    for r in data.get("results", []):
        out.append({"id": r.get("trackId"), "name": r.get("trackName"), "seller": r.get("sellerName"), "genre": r.get("primaryGenreName"),
                    "rating": r.get("averageUserRating"), "ratings": r.get("userRatingCount"), "released": (r.get("releaseDate") or "")[:10],
                    "updated": (r.get("currentVersionReleaseDate") or "")[:10], "langs": r.get("languageCodesISO2A"),
                    "desc": (r.get("description") or "")[:600].replace("\n", " ")})
    return out

# ---------- Play ----------
def play_details(pkg, gl="IN"):
    url = f"https://play.google.com/store/apps/details?id={pkg}&hl=en&gl={gl}"
    try:
        h = get(url)
    except Exception as e:
        return {"pkg": pkg, "error": str(e)}
    d = {"pkg": pkg}
    m = re.search(r"<title[^>]*>(.*?)</title>", h, re.S); d["title"] = html.unescape(m.group(1)).replace(" - Apps on Google Play","").strip() if m else None
    m = re.search(r'<meta [^>]*itemprop="description" content="(.*?)"', h); d["short"] = html.unescape(m.group(1)) if m else None
    m = re.search(r'aria-label="Rated ([\d.]+) stars out of five stars"', h); d["rating"] = m.group(1) if m else None
    m = re.search(r'>([\d.,]+[KMB]?) reviews<', h); d["reviews"] = m.group(1) if m else None
    m = re.search(r'>([\d.,]+[KMB]?\+)<[^>]*>(?:<[^>]*>){0,3}\s*Downloads', h); d["downloads"] = m.group(1) if m else None
    d["ads"] = "Contains ads" in h; d["iap"] = "In-app purchases" in h
    m = re.search(r'Updated on<[^>]*>(?:<[^>]*>)*([A-Z][a-z]{2} \d{1,2}, \d{4})<', h); d["updated"] = m.group(1) if m else None
    m = re.search(r'/store/apps/dev(?:eloper)?\?id=[^"]*"[^>]*>(?:<[^>]*>)*([^<]+)<', h); d["dev"] = html.unescape(m.group(1)).strip() if m else None
    d["cats"] = sorted(set(re.findall(r'/store/apps/category/([A-Z_]+)"', h)))
    m = re.search(r'data-g-id="description"[^>]*>(.*?)</div>', h, re.S); d["desc"] = strip(m.group(1))[:700].replace("\n", " ") if m else None
    m = re.search(r'In-app purchases<[^>]*>(?:<[^>]*>)*\s*([^<]*per item[^<]*)<', h); d["iap_range"] = m.group(1) if m else None
    return d

def play_search(q, gl="IN", n=14):
    url = "https://play.google.com/store/search?" + urllib.parse.urlencode({"q": q, "c": "apps", "hl": "en", "gl": gl})
    try:
        h = get(url)
    except Exception as e:
        return [{"error": str(e)}]
    rows, seen = [], set()
    for m in re.finditer(r'href="/store/apps/details\?id=([^"&]+)"', h):
        pkg = m.group(1)
        if pkg in seen: continue
        seen.add(pkg)
        ahead = h[m.end(): m.end()+1500]
        t = re.search(r'class="DdYX5">([^<]+)<', ahead); dv = re.search(r'class="wMUdtb">([^<]+)<', ahead)
        rt = re.search(r'aria-label="Rated ([\d.]+) stars', ahead)
        rows.append({"pkg": pkg, "title": html.unescape(t.group(1)) if t else None, "dev": html.unescape(dv.group(1)) if dv else None, "rating": rt.group(1) if rt else None})
        if len(rows) >= n: break
    return rows

if __name__ == "__main__":
    mode = sys.argv[1]
    out = {}
    if mode == "itunes":
        for spec in sys.argv[2:]:
            term, country = (spec.split("@") + ["in"])[:2]
            try: out[f"{term}@{country}"] = itunes_search(term, country)
            except Exception as e: out[f"{term}@{country}"] = str(e)
            time.sleep(1.2)
    elif mode == "lookup":
        for spec in sys.argv[2:]:
            i, country = (spec.split("@") + ["in"])[:2]
            try: out[spec] = itunes_lookup(i, country)
            except Exception as e: out[spec] = str(e)
            time.sleep(1.2)
    elif mode == "play":
        for pkg in sys.argv[2:]:
            out[pkg] = play_details(pkg); time.sleep(0.8)
    elif mode == "playsearch":
        for q in sys.argv[2:]:
            out[q] = play_search(q); time.sleep(0.8)
    print(json.dumps(out, ensure_ascii=False, indent=1))
