// Diner bubbles: "eaten, waiting to pay" = an empty steel plate + a ₹ chit (G11's charpai wait).
// addChits(id, [[cx, top], ...]) in canvas px; a bubble is 66 x 38 so it covers an order bubble.
var CHIT = '<svg width="22" height="26" viewBox="0 0 22 26" style="position:absolute;left:35px;top:4px">' +
  '<path d="M1.5,1.5 H15 L20.5,7 V24.5 H1.5 Z" fill="#ffe9a8" stroke="#7a2a12" stroke-width="1.8"/>' +
  '<path d="M15,1.5 V7 H20.5" fill="#e3c06a" stroke="#7a2a12" stroke-width="1.4"/>' +
  '<text x="10.5" y="20.5" font-size="15" font-weight="800" text-anchor="middle" fill="#b0281a" font-family="Baloo 2">₹</text></svg>';
var PLATE = '<svg width="28" height="18" viewBox="0 0 28 18" style="position:absolute;left:6px;top:10px">' +
  '<ellipse cx="14" cy="9" rx="13" ry="7.5" fill="#d9dee3" stroke="#6b7680" stroke-width="1.5"/>' +
  '<ellipse cx="14" cy="9" rx="8" ry="4.3" fill="#eef1f4"/></svg>';
function addChits(id, list) {
  var host = document.getElementById(id), h = "";
  list.forEach(function (p) {
    h += '<div class="a bub" style="left:' + (p[0] - 33) + 'px;top:' + p[1] + 'px;width:66px">' + PLATE + CHIT + '</div>';
  });
  host.innerHTML = h;
}
// Food bubbles drawn the same way (kind: list of icon ids) for frames that need new ones.
