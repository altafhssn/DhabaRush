# Dhaba Rush i18n check (launch blockers track B).
# Every msgid the code / data uses must be in i18n/hi.po: tr("..."), UiKit.t("..."),
# TranslationServer.translate("..."), the economy_v3.json text fields and the
# staff names (msgctxt "name"). Placeholders are compared too.
#   /Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I tools/i18n/check_po.py [--literals]
# --literals also lists other English-looking literals in scripts/v3/ui and
# scripts/v3/tutorial (node names, debug prints ... and any label text that
# was forgotten). Exit code = number of missing msgids.
import re, sys, os, json, glob
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
def parse_po(path):
    ents = {}
    ctx = ''; mid = None; mstr = None; cur = None
    def unq(s):
        s = s.strip()[1:-1]
        return s.replace('\\n', '\n').replace('\\"', '"').replace('\\t', '\t').replace('\\\\', '\\')
    for line in open(path, encoding='utf-8').read().split('\n') + ['']:
        if line.startswith('msgctxt '):
            if mid is not None: ents[(ctx, mid)] = mstr; mid = None
            ctx = unq(line[8:]); cur = 'c'
        elif line.startswith('msgid '):
            if mid is not None and cur == 's': ents[(ctx, mid)] = mstr; ctx = ''
            mid = unq(line[6:]); cur = 'i'
        elif line.startswith('msgstr '):
            mstr = unq(line[7:]); cur = 's'
        elif line.startswith('"'):
            if cur == 'i': mid += unq(line)
            elif cur == 's': mstr += unq(line)
            elif cur == 'c': ctx += unq(line)
        elif line.strip() == '' and mid is not None and cur == 's':
            ents[(ctx, mid)] = mstr; mid = None; ctx = ''; cur = None
    ents.pop(('', ''), None)
    return ents
po = parse_po(os.path.join(ROOT, 'i18n/hi.po'))
ids = {k[1] for k in po}
miss = []
STR = r'"((?:[^"\\]|\\.)*)"'
pat = re.compile(r'(?:\btr|UiKit\.t|TranslationServer\.translate)\(\s*' + STR + r'(?:\s*,\s*' + STR + r')?')
pat_if = re.compile(r'(?:\btr|UiKit\.t)\(\s*' + STR + r'\s+if\s+[^)]*?\belse\s+' + STR)
files = glob.glob(ROOT + '/scripts/**/*.gd', recursive=True)
def unesc(s): return s.replace('\\n', '\n').replace('\\"', '"')
for f in files:
    src = open(f, encoding='utf-8').read()
    for m in pat.finditer(src):
        mid = unesc(m.group(1)); ctx = unesc(m.group(2) or '')
        if (ctx, mid) not in po: miss.append((os.path.relpath(f, ROOT), ctx, mid))
    for m in pat_if.finditer(src):
        for g in (1, 2):
            mid = unesc(m.group(g))
            if ('', mid) not in po: miss.append((os.path.relpath(f, ROOT), '', mid))
# economy data
eco = json.load(open(ROOT + '/data/economy_v3.json', encoding='utf-8'))
def walk(o, path):
    if isinstance(o, dict):
        for k, v in o.items(): yield from walk(v, path + [k])
    elif isinstance(o, list):
        for i, v in enumerate(o): yield from walk(v, path + [i])
    elif isinstance(o, str): yield path, o
TEXT_KEYS = {'name', 'noun', 'build_desc', 'serve_text', 'build_text', 'card_name', 'desc', 'text'}
for path, v in walk(eco, []):
    k = path[-1] if not isinstance(path[-1], int) else path[-2]
    if path[0] == 'stations' and k in TEXT_KEYS and path[-2:] != ['daynight']:
        if ('', v) not in po: miss.append(('economy', '', v))
    if path[:2] == ['tasks', 'texts'] or (path[:2] == ['tasks', 'defs'] and k == 'text'):
        if ('', v) not in po: miss.append(('economy', '', v))
    if k == 'staff' or (path[0] == 'waiters' and k == 'names'):
        if ('name', v) not in po: miss.append(('economy', 'name', v))
PH = re.compile(r'%(?:\d*\.\d+|0?\d+)?[dsf%]|\{[a-z_]+\}|\[/?[kn]\]|\n')
bad = [(k, v) for k, v in po.items() if sorted(PH.findall(k[1])) != sorted(PH.findall(v)) or not v.strip()]
for k, v in bad:
    print('PLACEHOLDERS / EMPTY:', k, '->', v)
print('msgids in hi.po:', len(po))
print('MISSING (%d):' % len(miss))
for x in sorted(set(miss)): print('  ', x)
# English-looking literals in the owned UI sources that are not msgids
if '--literals' in sys.argv:
    lit = re.compile(STR)
    allow = re.compile(r'^[a-z0-9_:%./|\-]*$')
    for f in sorted(glob.glob(ROOT + '/scripts/v3/ui/*.gd') + glob.glob(ROOT + '/scripts/v3/tutorial/*.gd')):
        for n, line in enumerate(open(f, encoding='utf-8').read().split('\n'), 1):
            s = line.strip()
            if s.startswith('#'): continue
            code = line.split(' #')[0] if '"' not in line.split(' #')[-1] else line
            for m in lit.finditer(code):
                t = unesc(m.group(1))
                if not re.search(r'[A-Za-z]{2}', t) or allow.match(t): continue
                if t in ids: continue
                print('LIT %s:%d %r' % (os.path.relpath(f, ROOT), n, t))

sys.exit(len(set(miss)) + len(bad))
