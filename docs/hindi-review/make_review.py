#!/usr/bin/env python3
"""Builds the Hindi native-speaker review sheet (soft-launch checklist B14).

  /usr/bin/python3 docs/hindi-review/make_review.py

Reads every Hindi text a player or tester will see and writes, next to this
script:
  hindi-review.csv   one row per text, for Google Sheets / Excel (UTF-8 with BOM)
  hindi-review.md    the same rows, readable, grouped

Sources (re-run after any of them changes; the IDs are positions, so a re-run
renumbers):
  i18n/hi.po                         the game (every msgid / msgstr pair)
  docs/store/play-listing.md         Hindi store listing, title, short text, captions
  docs/legal/privacy-policy.html     section 18, the Hindi summary
  docs/shorts/clips.json             the Hindi Shorts (burned-in text, titles, descriptions)
  docs/launch/tester-kit.md          tester messages and the feedback form
Priority 1 = read first (docs/launch/hindi.md section 4, everything new or
changed since the 23 Oct list in baseline_2026-10-23.json, and every public
text outside the game). Priority 2 = the rest of the game.
"""
import csv
import html
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
PO = os.path.join(ROOT, "i18n", "hi.po")
LISTING = os.path.join(ROOT, "docs", "store", "play-listing.md")
POLICY = os.path.join(ROOT, "docs", "legal", "privacy-policy.html")
SHORTS = os.path.join(ROOT, "docs", "shorts", "clips.json")
KIT = os.path.join(ROOT, "docs", "launch", "tester-kit.md")
BASELINE = os.path.join(HERE, "baseline_2026-10-23.json")

# hindi.md section 4: words to check first, with the reason shown to the reviewer.
WATCH = [
    ("रखें", "hindi.md §4 item 3: HIRE = रखें"),
    ("इनाम लें", "hindi.md §4 item 3: CLAIM = इनाम लें"),
    ("से॰", "hindi.md §4 item 4: short form से॰ (seconds)"),
    ("घं ", "hindi.md §4 item 4: short forms घं / मि"),
    ("लेवल %", "hindi.md §4 item 4: लेवल 25"),
    ("अभी बेस्ट", "hindi.md §4 item 5: Hinglish BEST NOW"),
    ("सीटें फ़ुल", "hindi.md §4 item 5: Hinglish SEATS FULL"),
    ("टॉप डिश", "hindi.md §4 item 5: Hinglish TOP DISH"),
    ("दिक़्क़त", "hindi.md §4 item 6: PROBLEM = दिक़्क़त"),
    ("दफ़्तर", "hindi.md §4 item 8: BUILD panel title दफ़्तर"),
    ("मुसाफ़िरों", "hindi.md §4 item 9: plural मुसाफ़िरों"),
    ("कृपया", "hindi.md §4 item 11: is कृपया too formal?"),
]

# English meaning of the policy's Hindi summary (section 18), by the start of
# each Hindi item. An item not listed here gets a pointer to the English text.
POLICY_GLOSS = {
    "यह सारांश": "This summary is a simpler form of the English policy above. If they differ, the English policy applies.",
    "इस गेम में कोई अकाउंट": "There is no account in this game. We do not ask for your name, email, phone number, contacts, photos or exact location.",
    "आपकी गेम प्रगति": "Your game progress is saved only on your phone. It is deleted when you uninstall the game or clear its storage.",
    "विज्ञापन Google AdMob": "Ads are shown by Google AdMob. For this Google uses your phone's advertising ID, approximate location from the IP address, device information and your activity on ads. You can reset or delete the advertising ID in Android Settings > Google > Ads.",
    "गेम को बेहतर बनाने के लिए": "To improve the game we use GameAnalytics, only with your permission. We ask a few minutes into your first game (if you close the game before then, the next time you play). Until you answer, and if you choose NO THANKS, nothing is sent to GameAnalytics. If you choose ALLOW it receives a random Player ID, device information and your activity in the game (such as the tutorial, upgrades, ads watched); and the advertising ID if the phone makes it available. You can turn this off or on at any time in the game's Settings > ANALYTICS.",
    "खरीदारी Google Play": "Purchases go through Google Play. We never see your card, UPI or bank details.",
    "हम आपका निजी डेटा": "We do not sell your personal data.",
    "यह गेम 13 साल": "This game is for players aged 13 and over. Players under 18 should play only with a parent's or guardian's permission.",
    "डिजिटल व्यक्तिगत डेटा": "Under the Digital Personal Data Protection Act, 2023 you can ask for a summary of your data, ask for it to be corrected or erased, withdraw consent and complain.",
    "डेटा मिटवाने": "To have data deleted, ask a question or complain, write to info@littletagartstudios.com. For deletion, also write your Player ID: it shows at the bottom of the game's Settings (tap it to copy). Grievance Officer: [name]. We confirm a complaint within 48 hours and resolve it within 30 days. If you are not satisfied, you can complain to the Data Protection Board of India.",
}


def read(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()


# ---------------------------------------------------------------- hi.po
def parse_po(path):
    """Entries in file order: section title, translator notes, context, msgid, msgstr."""
    lines = read(path).splitlines()
    entries = []
    section = ""
    comments = []
    ctx = None
    i = 0
    while i < len(lines):
        l = lines[i]
        if l.startswith("# =====") and i + 1 < len(lines) and lines[i + 1].startswith("# ") \
                and not lines[i + 1].startswith("# ====="):
            section = lines[i + 1][2:]
            i += 2
            while i < len(lines) and not lines[i].startswith("# ====="):
                i += 1
            i += 1
            comments = []
            continue
        if l.startswith("#. "):
            comments.append(l[3:].strip())
        elif l.startswith("msgctxt "):
            ctx = json.loads(l[8:])
        elif l.startswith("msgid "):
            mid = json.loads(l[6:])
            i += 1
            while i < len(lines) and lines[i].startswith('"'):
                mid += json.loads(lines[i])
                i += 1
            mstr = ""
            if i < len(lines) and lines[i].startswith("msgstr "):
                mstr = json.loads(lines[i][7:])
                i += 1
                while i < len(lines) and lines[i].startswith('"'):
                    mstr += json.loads(lines[i])
                    i += 1
            if mid:
                entries.append({"section": section, "note": " ".join(comments), "ctx": ctx or "", "en": mid, "hi": mstr})
            comments = []
            ctx = None
            continue
        i += 1
    return entries


def game_rows():
    base = json.load(open(BASELINE, encoding="utf-8"))["entries"]
    out = []
    for e in parse_po(PO):
        title = e["section"].split(" (")[0].split(". ")[0].strip().rstrip(".") or "Game"
        title = title.replace("Game data: ", "")
        key = e["ctx"] + "\u0004" + e["en"]
        why = []
        if title.startswith("Munshi"):
            why.append("hindi.md §4 item 1: Munshi-ji's lines")
        if title.startswith("Ads, purchases"):
            why.append("hindi.md §4 item 11: ad / purchase / consent strings")
        if title.startswith("Analytics consent"):
            why.append("new 27 Oct: analytics consent card")
        if "joke" in e["note"]:
            why.append("hindi.md §4 item 7: dish joke")
        if e["ctx"] == "name" or "gender" in e["note"]:
            why.append("hindi.md §4 item 2: names and gender")
        for w, reason in WATCH:
            if w in e["hi"]:
                why.append(reason)
        if key not in base:
            why.append("new since the 23 Oct list")
        elif base[key] != e["hi"]:
            why.append("Hindi changed since 23 Oct")
        note = e["note"]
        if e["ctx"]:
            note = ("[%s] " % e["ctx"]) + note
        keep = sorted(set(re.findall(r"%[0-9.]*[sdf]|\{\w+\}|\[/?[kn]\]", e["en"])))
        if keep:
            note += (" " if note else "") + "Keep " + " ".join(keep) + "."
        out.append({"group": "Game: " + title, "where": note.strip(), "en": e["en"], "hi": e["hi"],
                    "prio": 1 if why else 2, "why": "; ".join(dict.fromkeys(why))})
    return out


# ---------------------------------------------------------------- store listing
def listing_rows():
    s = read(LISTING)
    out = []
    t_en = re.search(r"### 1a\..*?\n(.*?)### 1b\.", s, re.S).group(1)
    t_hi = re.search(r"### 1b\..*?\n(.*?)## 2\.", s, re.S).group(1)

    def cell(block, field):
        m = re.search(r"^\| %s \| \d+ \| (.*?) \| [\d,]+ \|$" % re.escape(field), block, re.M)
        return m.group(1) if m else ""

    out.append({"where": "Play listing: app name (30 characters max)", "en": cell(t_en, "App name"), "hi": cell(t_hi, "App name")})
    out.append({"where": "Play listing: short description (80 max)", "en": cell(t_en, "Short description"), "hi": cell(t_hi, "Short description")})
    fe = re.search(r"Full description:\n\n```\n(.*?)```", t_en, re.S).group(1)
    fh = re.search(r"Full description:\n\n```\n(.*?)```", t_hi, re.S).group(1)
    le = [l for l in fe.splitlines() if l.strip()]
    lh = [l for l in fh.splitlines() if l.strip()]
    if len(le) == len(lh):
        for i, (a, b) in enumerate(zip(le, lh), 1):
            out.append({"where": "Play listing: full description, line %d" % i, "en": a, "hi": b})
    else:
        out.append({"where": "Play listing: full description (whole)", "en": fe.strip(), "hi": fh.strip()})
    for m in re.finditer(r"^\| (\d) \| (.*?) \| (.*?) \| (.*?) \| .*?\|$", s, re.M):
        out.append({"where": "Play screenshot %s caption (on the image: %s)" % (m.group(1), m.group(4)),
                    "en": m.group(2).replace("**", ""), "hi": m.group(3).replace("**", "")})
    for r in out:
        r.update({"group": "Store listing (Play, Hindi)", "prio": 1, "why": "public: Play store page"})
    return out


# ---------------------------------------------------------------- policy
def policy_rows():
    s = read(POLICY)
    m = re.search(r'<h2 id="hindi".*?>(.*?)</h2>(.*?)</div>', s, re.S)
    out = []
    if not m:
        return out
    items = [("title", m.group(1))]
    for p in re.findall(r"<p[^>]*>(.*?)</p>", m.group(2), re.S):
        items.append(("note", p))
    for li in re.findall(r"<li>(.*?)</li>", m.group(2), re.S):
        items.append(("item", li))
    k = 0
    for kind, raw in items:
        hi = html.unescape(re.sub(r"<[^>]+>", "", raw)).strip()
        hi = re.sub(r"\s+", " ", hi)
        gloss = next((v for p, v in POLICY_GLOSS.items() if hi.startswith(p)), None)
        if kind == "title":
            gloss = "18. Summary in Hindi"
        k += kind == "item"
        out.append({"group": "Privacy policy, section 18 (Hindi summary)",
                    "where": "policy heading" if kind == "title" else ("policy note" if kind == "note" else "policy point %d" % k),
                    "en": gloss or "(meaning: see the English policy, 'The short version' and sections 3 to 12)",
                    "hi": hi, "prio": 1, "why": "public: privacy policy page"})
    return out


# ---------------------------------------------------------------- Shorts
def shorts_rows():
    d = json.load(open(SHORTS, encoding="utf-8"))
    out = []
    for c in d["clips"]:
        if c.get("lang") != "hi":
            continue
        t = c["segments"][0].get("text", {})
        u = c["upload"]
        tag = "Short %s (%s)" % (c["id"], c["slot"].split(" · ")[1])
        pairs = [("text on the video, first 3 s", t.get("hook_en", ""), t.get("hook", "")),
                 ("text on the video, last 3 s", t.get("caption_en", ""), t.get("caption", "")),
                 ("YouTube title", u.get("title_en", ""), u.get("title", ""))]
        for i, (a, b) in enumerate(zip(u.get("description_en", "").split("\n\n"), u.get("description", "").split("\n\n")), 1):
            pairs.append(("YouTube description, paragraph %d" % i, a, b))
        pairs.append(("pinned comment", u.get("pinned_comment_en", ""), u.get("pinned_comment", "")))
        for where, en, hi in pairs:
            if hi:
                out.append({"group": "YouTube Shorts (Hindi)", "where": tag + ": " + where,
                            "en": en.replace("\n", " / "), "hi": hi.replace("\n", " / ").replace("[h]", "").replace("[/h]", ""),
                            "prio": 1, "why": "public: YouTube"})
    return out


# ---------------------------------------------------------------- tester kit
def kit_rows():
    s = read(KIT)
    blocks = {}
    for m in re.finditer(r"<!-- review:(\w+):(en|hi) -->\s*```text\n(.*?)```", s, re.S):
        blocks.setdefault(m.group(1), {})[m.group(2)] = m.group(3)
    names = {"recruit": "recruiting post", "welcome": "welcome message", "try": "what to try",
             "reminder": "day-7 reminder", "thanks": "after the test"}
    out = []
    for key, pair in blocks.items():
        if "en" not in pair or "hi" not in pair:
            continue
        le = [l for l in pair["en"].splitlines() if l.strip()]
        lh = [l for l in pair["hi"].splitlines() if l.strip()]
        if len(le) == len(lh):
            for i, (a, b) in enumerate(zip(le, lh), 1):
                out.append({"where": "%s, line %d" % (names.get(key, key), i), "en": a, "hi": b})
        else:
            out.append({"where": names.get(key, key), "en": pair["en"].strip(), "hi": pair["hi"].strip()})
    form = re.search(r"<!-- review:form -->\n(.*?)\n\n", s, re.S)
    if form:
        for m in re.finditer(r"^\| (\d+) \| (.*?) \| (.*?) \| (.*?) \| (.*?) \| (.*?) \|$", form.group(1), re.M):
            out.append({"where": "feedback form, question %s (%s)" % (m.group(1), m.group(4)), "en": m.group(2), "hi": m.group(3)})
            if m.group(6).strip():
                out.append({"where": "feedback form, question %s answers" % m.group(1), "en": m.group(5), "hi": m.group(6)})
    for r in out:
        r.update({"group": "Tester kit (WhatsApp messages, feedback form)", "prio": 1, "why": "sent to testers"})
    return out


# ---------------------------------------------------------------- output
COLS = ["ID", "Priority", "Why first", "Group", "Where it shows / note", "English", "Hindi now",
        "OK? (yes / no)", "Better Hindi (if not OK)", "Reviewer note"]


def main():
    groups = [game_rows(), listing_rows(), policy_rows(), shorts_rows(), kit_rows()]
    rows = []
    seen = {}
    for r in (r for g in groups for r in g):
        key = (r["group"], r["en"], r["hi"])
        if key in seen and not r["group"].startswith("Game"):
            first = seen[key]
            first["where"] += " (same text also in: %s)" % r["where"]
            continue
        seen[key] = r
        rows.append(r)
    for i, r in enumerate(rows, 1):
        r["id"] = "H%03d" % i
    with open(os.path.join(HERE, "hindi-review.csv"), "w", encoding="utf-8-sig", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(COLS)
        for r in rows:
            w.writerow([r["id"], r["prio"], r.get("why", ""), r["group"], r.get("where", ""), r["en"], r["hi"], "", "", ""])
    write_md(rows)
    p1 = sum(1 for r in rows if r["prio"] == 1)
    print("rows %d (priority 1: %d, priority 2: %d)" % (len(rows), p1, len(rows) - p1))
    by = {}
    for r in rows:
        by[r["group"]] = by.get(r["group"], 0) + 1
    for g, n in by.items():
        print("  %4d  %s" % (n, g))


def md_cell(t):
    return t.replace("|", "\\|").replace("\n", "<br>")


def write_md(rows):
    p1 = sum(1 for r in rows if r["prio"] == 1)
    order = []
    for r in rows:
        if r["group"] not in order:
            order.append(r["group"])
    lines = [
        "# Hindi review sheet (B14)",
        "",
        "Every Hindi text that players, store visitors and testers will see, next to its English source. "
        "For a native Hindi speaker; about 3–4 hours. Generated by `make_review.py` from the game's "
        "`i18n/hi.po`, the Play listing, the privacy policy's Hindi summary, the Hindi Shorts and the tester kit.",
        "",
        "**%d texts. %d are priority 1 (read first), %d are priority 2.**" % (len(rows), p1, len(rows) - p1),
        "",
        "## How to review",
        "",
        "1. Open `hindi-review.csv` in Google Sheets (File › Import › Upload) or Excel. One row per text.",
        "2. Start with **priority 1**: filter column B to 1. The column \"Why first\" says why "
        "(the questions in [../launch/hindi.md](../launch/hindi.md) section 4, texts that are new since 23 Oct, "
        "and everything public: store page, privacy policy, YouTube, tester messages).",
        "3. For each row write **yes** in \"OK?\", or **no** plus your better Hindi. A short reason in \"Reviewer note\" helps.",
        "4. Send the sheet back. Claude applies the fixes in the 0.3.9 tester update (about Wed 18 Nov).",
        "",
        "What we want:",
        "",
        "- Everyday Hindi as Indian apps write it, not formal or textbook Hindi. Game words people say in English stay English in Devanagari (अपग्रेड, लेवल, स्टाफ़, वेटर).",
        "- Polite imperative for instructions (करें, रखें, बनाएँ). Munshi-ji is warm and respectful and calls the player सेठ जी.",
        "- Short: most texts sit on buttons and small labels. The note often gives the space (\"230 px at 26 px\" means about 12–15 Hindi letters).",
        "- Keep `%s`, `%d`, `{n}`, `{name}` and the `[k]…[/k]` tags exactly as they are (the note says when a row has them).",
        "- Store, policy and YouTube texts: natural and correct first, then short.",
        "",
        "Groups: " + " · ".join("%s (%d)" % (g, sum(1 for r in rows if r["group"] == g)) for g in order),
        "",
    ]
    for g in order:
        lines += ["## " + g, "", "| ID | P | English | Hindi | Where / why |", "|---|---|---|---|---|"]
        for r in rows:
            if r["group"] != g:
                continue
            note = r.get("where", "")
            if r.get("why") and r["prio"] == 1 and not r["group"].startswith(("Store", "Privacy", "YouTube", "Tester")):
                note = (note + " · " if note else "") + "**" + r["why"] + "**"
            lines.append("| %s | %d | %s | %s | %s |" % (r["id"], r["prio"], md_cell(r["en"]), md_cell(r["hi"]), md_cell(note)))
        lines.append("")
    with open(os.path.join(HERE, "hindi-review.md"), "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines))


if __name__ == "__main__":
    main()
