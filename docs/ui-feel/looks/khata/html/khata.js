/* Dhaba Rush · khata look · icon sprite for the mockups.
   Style rules (style.md "Icons"): a 48 x 48 grid, one brown-black ink outline
   (2.4 units), flat fills from the world palette, no gradients, no gloss,
   objects from a highway dhaba instead of stock UI glyphs.
   Usage: <svg class="ic" width="26" height="26"><use href="#i-chai"/></svg> */
(function () {
  var INK = '#2B2420', S = 'stroke="' + INK + '" stroke-width="2.4" stroke-linejoin="round" stroke-linecap="round"';
  function gear() {
    var p = [], n = 8, R = 20, r = 14.5, cx = 24, cy = 24;
    for (var i = 0; i < n; i++) {
      var a0 = (i / n) * Math.PI * 2, w = Math.PI / n;
      var pts = [[r, a0 - w * 0.62], [R, a0 - w * 0.38], [R, a0 + w * 0.38], [r, a0 + w * 0.62]];
      pts.forEach(function (q, k) {
        var x = (cx + q[0] * Math.cos(q[1])).toFixed(2), y = (cy + q[0] * Math.sin(q[1])).toFixed(2);
        p.push((i === 0 && k === 0 ? 'M' : 'L') + x + ' ' + y);
      });
    }
    return p.join(' ') + 'Z';
  }
  var I = {
    'note': '<rect x="3" y="12" width="42" height="25" rx="3" fill="#6FBF73" ' + S + '/>' +
      '<path d="M37 12 L45 12 L45 19 Z" fill="#2C6E55"/>' +
      '<rect x="8" y="16.5" width="32" height="16" rx="2" fill="none" stroke="#2C6E55" stroke-width="1.6"/>' +
      '<ellipse cx="24" cy="24.5" rx="7.5" ry="6.6" fill="#F7EDD5" stroke="#2C6E55" stroke-width="1.6"/>' +
      '<text x="24" y="29.4" text-anchor="middle" font-family="Baloo2L" font-weight="800" font-size="13" fill="#2C6E55">₹</text>',
    'trend': '<path d="M5 37 L17 25 L25 31 L40 15" fill="none" stroke="#2F6B3A" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>' +
      '<path d="M29 13 L42 12 L41 25 Z" fill="#2F6B3A" stroke="#2F6B3A" stroke-width="2" stroke-linejoin="round"/>',
    'staff': '<path d="M7 46 C7 34 14 29 24 29 C34 29 41 34 41 46 Z" fill="#F7F4EE" ' + S + '/>' +
      '<path d="M10 33 L18 29.5 L33 45.5 L24 46 Z" fill="#D9412B" ' + S + '/>' +
      '<path d="M13.5 32 L26 45.5 M17 30.6 L29.5 45.6" stroke="#F7F4EE" stroke-width="1.6"/>' +
      '<circle cx="24" cy="17.5" r="9.5" fill="#D99A6A" ' + S + '/>' +
      '<path d="M14.6 16 C15 8 33 8 33.4 16 C30 12.5 18 12.5 14.6 16 Z" fill="' + INK + '"/>' +
      '<path d="M19.5 21.5 C22 20 26 20 28.5 21.5" fill="none" stroke="' + INK + '" stroke-width="2.4"/>',
    'build': '<rect x="4" y="28" width="28" height="15" rx="1.5" fill="#B5543A" ' + S + '/>' +
      '<path d="M4 35.5 H32 M17 28 V35.5 M10 35.5 V43 M24 35.5 V43" stroke="#E4D3A8" stroke-width="1.6"/>' +
      '<path d="M15 33 L29 17 L39 27 Z" fill="#C9CDD2" ' + S + '/>' +
      '<path d="M33.5 21.5 L38.5 16.5" stroke="' + INK + '" stroke-width="2.4"/>' +
      '<path d="M37 18 L44 11" stroke="' + INK + '" stroke-width="8" stroke-linecap="round"/>' +
      '<path d="M37 18 L44 11" stroke="#C68A4E" stroke-width="4.6" stroke-linecap="round"/>',
    'gear': '<path d="' + gear() + '" fill="#D9B36A" ' + S + '/>' +
      '<circle cx="24" cy="24" r="9" fill="#F7C548" ' + S + '/>' +
      '<circle cx="24" cy="24" r="3.6" fill="#7A4E2D" ' + S + '/>',
    'stats': '<rect x="7" y="7" width="31" height="35" rx="2.5" fill="#8E2436" ' + S + '/>' +
      '<rect x="37" y="9.5" width="4.5" height="30" fill="#F7EDD5" ' + S + '/>' +
      '<path d="M12 9.5 V39.5" stroke="#F7F4EE" stroke-width="1.5" stroke-dasharray="2.6 2"/>' +
      '<rect x="17" y="13" width="16" height="9" rx="1" fill="#F7EDD5" stroke="' + INK + '" stroke-width="1.6"/>' +
      '<path d="M20 16.2 H30 M20 19 H27" stroke="#2B3A67" stroke-width="1.3"/>' +
      '<path d="M15 30 H42 M42 30 l3 -2.5 M42 30 l3 2.5" stroke="#F7F4EE" stroke-width="1.8" fill="none"/>',
    'chai': '<path d="M11 19 L37 19 L32.5 43 L15.5 43 Z" fill="#B5653A" ' + S + '/>' +
      '<path d="M15 24 L17.5 40" stroke="#D69C64" stroke-width="2"/>' +
      '<ellipse cx="24" cy="19" rx="13" ry="3.6" fill="#A0622D" ' + S + '/>' +
      '<path d="M19 14 C16 11 21 8.5 18.5 4.5 M28.5 14 C25.5 11 30.5 8.5 28 4.5" fill="none" stroke="' + INK + '" stroke-width="2"/>',
    'roti': '<circle cx="21" cy="27" r="16" fill="#C9935A" ' + S + '/>' +
      '<circle cx="27" cy="23" r="16" fill="#E9C27B" ' + S + '/>' +
      '<path d="M21 17 q2 -1.5 3.5 0 M31 26 q2 -1.5 3.5 0 M22 29 q1.5 1 3 0 M32 15.5 q1 1 2 0" stroke="#A0622D" stroke-width="2.2" fill="none"/>' +
      '<circle cx="29" cy="31" r="1.6" fill="#A0622D"/><circle cx="18" cy="23" r="1.3" fill="#A0622D"/><circle cx="35" cy="20" r="1.2" fill="#A0622D"/>',
    'lassi': '<path d="M13 11 L35 11 L31.5 44 L16.5 44 Z" fill="#F6F2EA" ' + S + '/>' +
      '<path d="M12 11.5 C14 4.5 34 4.5 36 11.5 Z" fill="#FFF2A8" ' + S + '/>' +
      '<path d="M18 16 L20 40" stroke="#C9CDD2" stroke-width="2.2"/>' +
      '<circle cx="22" cy="8.4" r="1.4" fill="#FF9933"/><circle cx="27" cy="7.6" r="1.2" fill="#4F9B30"/>',
    'kadai': '<circle cx="6" cy="24" r="3.6" fill="none" stroke="' + INK + '" stroke-width="2.6"/>' +
      '<circle cx="42" cy="24" r="3.6" fill="none" stroke="' + INK + '" stroke-width="2.6"/>' +
      '<path d="M7 22 Q24 50 41 22 Z" fill="#4A4A52" ' + S + '/>' +
      '<ellipse cx="24" cy="22" rx="17" ry="4.6" fill="#E3A72F" ' + S + '/>' +
      '<circle cx="18" cy="21.5" r="1.4" fill="#4F9B30"/><circle cx="27" cy="22.5" r="1.4" fill="#D9412B"/><circle cx="31" cy="20.8" r="1.2" fill="#4F9B30"/>' +
      '<path d="M15 31 Q24 37 33 31" stroke="#5E646B" stroke-width="1.6" fill="none"/>',
    'kettle': '<path d="M15 20 Q24 5 33 20" fill="none" stroke="' + INK + '" stroke-width="3"/>' +
      '<path d="M34 31 L44 19 L45 22 L37 36 Z" fill="#C9CDD2" ' + S + '/>' +
      '<path d="M10 42 Q9 21 24 20 Q39 21 38 42 Z" fill="#C9CDD2" ' + S + '/>' +
      '<ellipse cx="24" cy="20.5" rx="6" ry="2" fill="#9FB4BF" ' + S + '/>' +
      '<path d="M15 28 Q14 34 15.5 38" stroke="#F7F4EE" stroke-width="2" fill="none"/>' +
      '<path d="M28 33 q2 1.5 4 0" stroke="#5E646B" stroke-width="1.4" fill="none"/>',
    'naan': '<path d="M9 39 C4 23 21 6 41 7 C43 26 30 43 9 39 Z" fill="#E9C27B" ' + S + '/>' +
      '<circle cx="20" cy="27" r="2.2" fill="#A0622D"/><circle cx="28" cy="20" r="1.8" fill="#A0622D"/><circle cx="31" cy="29" r="1.6" fill="#C9935A"/><circle cx="17" cy="34" r="1.4" fill="#A0622D"/><circle cx="34" cy="14" r="1.3" fill="#C9935A"/>' +
      '<path d="M22 14 Q27 11 32 11" stroke="#FFF2A8" stroke-width="2" fill="none"/>',
    'coffee': '<path d="M5 35 L43 35 L38 43 L10 43 Z" fill="#C9CDD2" ' + S + '/>' +
      '<path d="M15 12 L33 12 L30.5 37 L17.5 37 Z" fill="#C9CDD2" ' + S + '/>' +
      '<ellipse cx="24" cy="12" rx="9" ry="2.6" fill="#C98A5C" ' + S + '/>' +
      '<path d="M19 17 L20.5 33" stroke="#F7F4EE" stroke-width="1.8"/>' +
      '<path d="M21 7.5 C19 5.5 23 3.5 21.5 1.5 M27 7.5 C25 5.5 29 3.5 27.5 1.5" stroke="' + INK + '" stroke-width="1.8" fill="none"/>',
    'seats': '<path d="M5 18 L43 18 L43 34 L5 34 Z" fill="#E9C27B" ' + S + '/>' +
      '<path d="M5 22 L43 22 M5 26 L43 26 M5 30 L43 30 M11 18 V34 M17 18 V34 M23 18 V34 M29 18 V34 M35 18 V34" stroke="#C68A4E" stroke-width="1.2"/>' +
      '<rect x="3" y="15" width="5" height="25" rx="1.5" fill="#C68A4E" ' + S + '/><rect x="40" y="15" width="5" height="25" rx="1.5" fill="#C68A4E" ' + S + '/>',
    'cook': '<path d="M9 26 H39 L36 43 H12 Z" fill="#C9CDD2" ' + S + '/>' +
      '<path d="M6 26 H42" ' + S + '/>' +
      '<path d="M30 21 L41 5" stroke="' + INK + '" stroke-width="5.4" stroke-linecap="round"/>' +
      '<path d="M30 21 L41 5" stroke="#C68A4E" stroke-width="2.8" stroke-linecap="round"/>' +
      '<ellipse cx="27" cy="22" rx="6" ry="3.4" fill="#9FB4BF" ' + S + '/>' +
      '<path d="M16 21 C14 18 18 16 16 13" stroke="' + INK + '" stroke-width="1.8" fill="none"/>',
    'waiter': '<ellipse cx="24" cy="33" rx="20" ry="6" fill="#C9CDD2" ' + S + '/>' +
      '<path d="M12 18 L22 18 L20.5 31 L13.5 31 Z" fill="#B5653A" ' + S + '/>' +
      '<path d="M26 20 L36 20 L34.5 31 L27.5 31 Z" fill="#B5653A" ' + S + '/>' +
      '<path d="M15 14 C13 12 16 10 15 8 M30 15 C28 13 31 11 30 9" stroke="' + INK + '" stroke-width="1.6" fill="none"/>',
    'galla': '<rect x="5" y="17" width="38" height="25" rx="2" fill="#C68A4E" ' + S + '/>' +
      '<path d="M5 26 H43" ' + S + '/>' +
      '<rect x="19" y="29" width="10" height="7" rx="1" fill="#F7C548" ' + S + '/>' +
      '<path d="M13 17 L16 7 L36 9 L33 17 Z" fill="#6FBF73" ' + S + '/>' +
      '<path d="M22 12 h7" stroke="#2C6E55" stroke-width="1.6"/>',
    'levelup': '<path d="M24 4 L42 23 L31 23 L31 44 L17 44 L17 23 L6 23 Z" fill="#F7C548" ' + S + '/>' +
      '<path d="M21 27 V41" stroke="#FFF2A8" stroke-width="2.2"/>' +
      '<circle cx="24" cy="29" r="1.6" fill="#7A4E2D"/><circle cx="24" cy="38" r="1.6" fill="#7A4E2D"/>',
    'watch': '<path d="M24 4 v4" stroke="' + INK + '" stroke-width="3"/><circle cx="24" cy="4.5" r="2.6" fill="none" stroke="' + INK + '" stroke-width="1.8"/>' +
      '<circle cx="24" cy="27" r="17" fill="#F7C548" ' + S + '/>' +
      '<circle cx="24" cy="27" r="12.5" fill="#F7EDD5" stroke="#C98B1C" stroke-width="1.6"/>' +
      '<path d="M24 27 V18.5 M24 27 L30 30" stroke="' + INK + '" stroke-width="2.6" stroke-linecap="round"/>' +
      '<path d="M24 16.5 v1.6 M34.5 27 h-1.6 M24 37.5 v-1.6 M13.5 27 h1.6" stroke="' + INK + '" stroke-width="1.6"/>',
    'people': '<path d="M3 44 C3 33 9 29 16 29 C23 29 29 33 29 44 Z" fill="#2E8C8C" ' + S + '/>' +
      '<circle cx="16" cy="20" r="7.5" fill="#D99A6A" ' + S + '/>' +
      '<path d="M8 17.5 C8 9 24 9 24 17.5 Z" fill="#D9412B" ' + S + '/>' +
      '<path d="M21 44 C21 35 26 31 32 31 C38 31 44 35 44 44 Z" fill="#F7F4EE" ' + S + '/>' +
      '<circle cx="32" cy="23" r="6.5" fill="#C98A5C" ' + S + '/>' +
      '<path d="M25.6 21.5 C26 15.5 38 15.5 38.4 21.5 Z" fill="#F7F4EE" ' + S + '/>',
    'truck': '<rect x="3" y="12" width="28" height="22" rx="2" fill="#F7C548" ' + S + '/>' +
      '<path d="M6 16 H28 M6 30 H28" stroke="#D9412B" stroke-width="2"/>' +
      '<path d="M31 18 H39 L45 26 V34 H31 Z" fill="#3FB8BE" ' + S + '/>' +
      '<path d="M34 21 H38 L41.5 26 H34 Z" fill="#A9D8E6" stroke="' + INK + '" stroke-width="1.6"/>' +
      '<circle cx="12" cy="36" r="4.6" fill="#2A2A2A" ' + S + '/><circle cx="37" cy="36" r="4.6" fill="#2A2A2A" ' + S + '/>',
    'thali': '<ellipse cx="24" cy="27" rx="21" ry="15" fill="#C9CDD2" ' + S + '/>' +
      '<ellipse cx="24" cy="27" rx="16" ry="10.5" fill="none" stroke="#9FB4BF" stroke-width="1.6"/>' +
      '<circle cx="16" cy="25" r="5" fill="#E3A72F" ' + S + '/><circle cx="29" cy="22" r="4.6" fill="#4F9B30" ' + S + '/>' +
      '<path d="M22 33 C26 29 33 30 35 33 C32 36 25 36 22 33 Z" fill="#E9C27B" ' + S + '/>',
    'table': '<path d="M5 17 L43 17 L43 23 L5 23 Z" fill="#C68A4E" ' + S + '/>' +
      '<path d="M9 23 V40 M39 23 V40" stroke="' + INK + '" stroke-width="3.6"/>' +
      '<circle cx="36" cy="35" r="8" fill="#2F6B3A" ' + S + '/><path d="M36 31 v8 M32 35 h8" stroke="#F7F4EE" stroke-width="2.6"/>',
    'chest': '<path d="M5 22 Q5 11 24 11 Q43 11 43 22 Z" fill="#2C6E55" ' + S + '/>' +
      '<rect x="5" y="22" width="38" height="20" rx="1.5" fill="#2E7D32" ' + S + '/>' +
      '<path d="M5 22 H43" stroke="' + INK + '" stroke-width="2.4"/>' +
      '<path d="M5 26 V22 H9 M43 26 V22 H39 M5 38 V42 H9 M43 38 V42 H39" stroke="#F7C548" stroke-width="3" fill="none"/>' +
      '<rect x="20" y="19" width="8" height="9" rx="1.2" fill="#F7C548" ' + S + '/>' +
      '<circle cx="15" cy="33" r="3.2" fill="#FF8A1F"/><circle cx="33" cy="33" r="3.2" fill="#FF8A1F"/>' +
      '<circle cx="15" cy="33" r="1.2" fill="#F7C548"/><circle cx="33" cy="33" r="1.2" fill="#F7C548"/>',
    'play': '<circle cx="24" cy="24" r="20" fill="#2E8C8C" ' + S + '/><path d="M19 15 L34 24 L19 33 Z" fill="#F7EDD5"/>',
    'info': '<circle cx="24" cy="24" r="19" fill="#D9B36A" ' + S + '/><circle cx="24" cy="15" r="2.8" fill="' + INK + '"/><path d="M24 22 V35" stroke="' + INK + '" stroke-width="5" stroke-linecap="round"/>',
    'tick': '<path d="M9 25 L20 36 L40 12" fill="none" stroke="#2B3A67" stroke-width="5.5" stroke-linecap="round" stroke-linejoin="round"/>',
    'cashcounter': '<rect x="5" y="20" width="38" height="23" rx="2" fill="#8E2436" ' + S + '/>' +
      '<rect x="3" y="16" width="42" height="6" rx="1.5" fill="#C68A4E" ' + S + '/>' +
      '<rect x="22" y="8" width="16" height="9" rx="1.5" fill="#C9CDD2" ' + S + '/><path d="M26 11 h8" stroke="#2B2420" stroke-width="1.4"/>' +
      '<circle cx="13" cy="31" r="3.4" fill="#F7C548"/><circle cx="24" cy="31" r="3.4" fill="#FF8A1F"/><circle cx="35" cy="31" r="3.4" fill="#F7C548"/>',
    'hand': '<path d="M17 44 L13 30 C11 26 15 23 18 27 L20 30 L19 9 C19 5 25 5 25 9 L25 22 C25 19 30 19 30 22 L30 24 C30 21 35 21 35 24 L35 26 C35 23 40 23 40 26 L40 34 C40 40 37 44 33 46 Z" fill="#FFFDF6" ' + S + '/>' +
      '<path d="M16 42 L34 46 L32 52 L14 48 Z" fill="#FF8A1F" ' + S + '/>'
  };
  var sym = Object.keys(I).map(function (k) {
    return '<symbol id="i-' + k + '" viewBox="0 0 48 48" overflow="visible">' + I[k] + '</symbol>';
  }).join('');
  var holder = document.createElement('div');
  holder.style.cssText = 'position:absolute;width:0;height:0;overflow:hidden';
  holder.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg">' + sym + '</svg>';
  document.body.insertBefore(holder, document.body.firstChild);
})();

/* helpers for repeated SVG marks */
function sealSVG(kind) { /* wax seal badge: kind '!' (red) or '+' (green) or a number */
  var fill = kind === '+' ? '#2F6B3A' : '#D9412B', rim = kind === '+' ? '#1F4A28' : '#8A2C2C';
  var g = kind === '+' ? '<path d="M15 9.5 v11 M9.5 15 h11" stroke="#F7F4EE" stroke-width="3.4" stroke-linecap="round"/>'
    : kind === '!' ? '<path d="M15 8.5 V16.5" stroke="#F7F4EE" stroke-width="3.6" stroke-linecap="round"/><circle cx="15" cy="21.3" r="2" fill="#F7F4EE"/>'
    : '<text x="15" y="21.6" text-anchor="middle" font-family="Baloo2L" font-weight="800" font-size="18" fill="#F7F4EE">' + kind + '</text>' /* critic fix: 18/30 of a 32 px seal = 19 px bold, large text, so 4.03:1 passes */;
  return '<svg viewBox="0 0 30 30" width="100%" height="100%"><path d="M15 1.5 C19 1 21 3.5 24 4.5 C27.5 6 28.5 9.5 28.6 13 C29.4 17 28 20.5 26 23.5 C23.5 27 19.5 28.6 15 28.5 C10.5 28.8 6.5 27.5 4 24 C1.6 20.6 1.2 17 1.6 13.2 C2 9.5 4 6 7.2 4 C9.6 2.5 12 1.6 15 1.5 Z" fill="' + fill + '" stroke="' + rim + '" stroke-width="1.4"/><circle cx="15" cy="15" r="9.6" fill="none" stroke="' + rim + '" stroke-width="1" opacity="0.7"/>' + g + '</svg>';
}
function closeSVG() { /* cross-stitch X on cloth with four brass rivets */
  return '<svg viewBox="0 0 58 58" width="100%" height="100%">' +
    '<path d="M18 18 L40 40 M40 18 L18 40" stroke="#F7F4EE" stroke-width="7" stroke-linecap="round"/>' +
    '<path d="M18 18 L40 40 M40 18 L18 40" stroke="#C9C2B4" stroke-width="1" stroke-dasharray="3 3" stroke-linecap="round" opacity="0.6"/>' +
    '<g fill="#D9B36A" stroke="#7A4E2D" stroke-width="1"><circle cx="8" cy="8" r="3"/><circle cx="50" cy="8" r="3"/><circle cx="8" cy="50" r="3"/><circle cx="50" cy="50" r="3"/></g></svg>';
}
function stampSVG(word, opts) { /* rubber stamp in red ink: a ring and one live word */
  opts = opts || {};
  var col = opts.color || '#C64A3A', w = opts.w || 80, h = opts.h || 40, fs = opts.fs || 18;
  var id = 'rough' + Math.floor(Math.random() * 1e6);
  return '<svg viewBox="0 0 ' + w + ' ' + h + '" width="100%" height="100%" style="overflow:visible">' +
    '<defs><filter id="' + id + '" x="-10%" y="-10%" width="120%" height="120%"><feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" seed="4" result="n"/>' +
    '<feColorMatrix in="n" type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 -1.6 1.75" result="m"/><feComposite in="SourceGraphic" in2="m" operator="in"/></filter></defs>' +
    '<g filter="url(#' + id + ')" fill="none" stroke="' + col + '">' +
    '<rect x="2" y="2" width="' + (w - 4) + '" height="' + (h - 4) + '" rx="5" stroke-width="2.6"/>' +
    '<rect x="5.5" y="5.5" width="' + (w - 11) + '" height="' + (h - 11) + '" rx="3" stroke-width="1"/>' +
    '<text x="' + w / 2 + '" y="' + (h / 2 + fs * 0.36) + '" text-anchor="middle" font-family="Eczar" font-weight="800" font-size="' + fs + '" fill="' + col + '" stroke="none" letter-spacing="' + (/[^\x00-\x7F]/.test(word) ? 0 : 1.5) + '">' + word + '</text></g></svg>';
}
function tickStampSVG(col) { /* round tick stamp: "entered in the book" */
  col = col || '#2B3A67';
  var id = 'rt' + Math.floor(Math.random() * 1e6);
  return '<svg viewBox="0 0 60 60" width="100%" height="100%" style="overflow:visible">' +
    '<defs><filter id="' + id + '"><feTurbulence type="fractalNoise" baseFrequency="0.8" numOctaves="2" seed="7" result="n"/>' +
    '<feColorMatrix in="n" type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 -1.6 1.75" result="m"/><feComposite in="SourceGraphic" in2="m" operator="in"/></filter></defs>' +
    '<g filter="url(#' + id + ')"><circle cx="30" cy="30" r="26" fill="none" stroke="' + col + '" stroke-width="3.4"/>' +
    '<circle cx="30" cy="30" r="20.5" fill="none" stroke="' + col + '" stroke-width="1.3"/>' +
    '<path d="M18 31 L26.5 39.5 L43 21" fill="none" stroke="' + col + '" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/></g></svg>';
}
function fillHTML(sel, fn) { document.querySelectorAll(sel).forEach(function (el) { el.innerHTML = fn(el); }); }
document.addEventListener('DOMContentLoaded', function () {
  fillHTML('[data-seal]', function (el) { return sealSVG(el.getAttribute('data-seal')); });
  fillHTML('[data-close]', function () { return closeSVG(); });
  fillHTML('[data-tick]', function (el) { return tickStampSVG(el.getAttribute('data-tick') || undefined); });
  fillHTML('[data-stamp]', function (el) {
    return stampSVG(el.getAttribute('data-stamp'), { w: +el.getAttribute('data-w') || 80, h: +el.getAttribute('data-h') || 40, fs: +el.getAttribute('data-fs') || 18, color: el.getAttribute('data-color') || undefined });
  });
});
