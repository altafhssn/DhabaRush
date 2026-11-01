"""Wraps the rendered icon PNGs into the SVG files Godot's Android exporter reads.

    /usr/bin/python3 docs/store/pipeline/wrap_icons.py <iconset dir> <out dir>

Writes android_fg.svg / android_mono.svg (embedded PNG; Godot's SVG loader,
ThorVG, draws embedded PNG images), android_bg.svg (pure vector: saffron radial
gradient + 18 sunburst rays, the same background as the Play icon) and
app_icon.svg (the legacy / project icon: the Play icon in a rounded square).
"""
import base64
import math
import pathlib
import sys

src = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])
out.mkdir(parents=True, exist_ok=True)


def b64(name: str) -> str:
    return base64.b64encode((src / name).read_bytes()).decode()


def svg(size: int, comment: str, body: str) -> str:
    return (f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
            f'width="{size}" height="{size}" viewBox="0 0 {size} {size}">\n'
            f'  <!-- {comment} -->\n{body}</svg>\n')


def image(size: int, name: str) -> str:
    return f'  <image x="0" y="0" width="{size}" height="{size}" href="data:image/png;base64,{b64(name)}"/>\n'


(out / "android_fg.svg").write_text(svg(432,
    "Android adaptive icon, FOREGROUND layer (108 dp = 432 px). Munshi-ji (his own game model, "
    "munshi_idle.glb) with a cutting-chai glass, all of it inside the 66 dp safe circle (radius 131 "
    "of 132 px). Embedded PNG; rebuild: docs/store/README.md. Same art as the 512 px Play icon.",
    image(432, "android_fg.png")))
(out / "android_mono.svg").write_text(svg(432,
    "Android 13+ themed icon, MONOCHROME layer: only the alpha counts (the launcher tints it). "
    "Munshi-ji's head and the chai glass with the moustache, brows and eyes cut out; same placement "
    "as android_fg.svg. Embedded PNG; rebuild: docs/store/README.md.",
    image(432, "android_mono.png")))
(out / "app_icon.svg").write_text(svg(512,
    "Legacy launcher icon (Android 7.x, launcher_icons/main_192x192) and candidate project icon: "
    "the Play store icon (Munshi-ji + cutting chai) in a rounded square. Embedded PNG; rebuild: "
    "docs/store/README.md.",
    image(512, "legacy_512.png")))

c = 470.0 / 1024.0 * 432.0
r = 1.2 * 432.0
rays = []
for i in range(18):
    a0 = 2.0 * math.pi * i / 18.0
    a1 = a0 + math.pi / 18.0
    rays.append(f"M{c:.1f} {c:.1f} L{c + r * math.cos(a0):.1f} {c + r * math.sin(a0):.1f} "
                f"L{c + r * math.cos(a1):.1f} {c + r * math.sin(a1):.1f} Z")
bg_body = (
    "  <defs>\n"
    f'    <radialGradient id="g" cx="{c:.1f}" cy="{c:.1f}" r="{0.62 * 432:.1f}" gradientUnits="userSpaceOnUse">\n'
    '      <stop offset="0" stop-color="#FFC867"/>\n'
    '      <stop offset="1" stop-color="#F08A2B"/>\n'
    "    </radialGradient>\n"
    "  </defs>\n"
    '  <rect width="432" height="432" fill="#F08A2B"/>\n'
    '  <rect width="432" height="432" fill="url(#g)"/>\n'
    f'  <path fill="#FFF7D9" fill-opacity="0.16" d="{" ".join(rays)}"/>\n')
(out / "android_bg.svg").write_text(svg(432,
    "Android adaptive icon, BACKGROUND layer: saffron sunburst (the same background as the 512 px "
    "Play icon), fully opaque.", bg_body))
print("wrote", ", ".join(sorted(p.name for p in out.glob("*.svg"))))
