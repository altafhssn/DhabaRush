// Shrink-to-fit (like bottleneck_meter.gd:55): any .fit with data-w is reduced 0.5 px at a time until it fits.
// .cap keeps its fixed width (centred text); .center elements are re-centred in their parent after fitting.
function fitAll() {
  document.querySelectorAll(".fit").forEach(function (el) {
    var w = parseFloat(el.getAttribute("data-w")), fs = parseFloat(getComputedStyle(el).fontSize), n = 0;
    var cap = el.classList.contains("cap");
    var probe = document.createElement("span");
    probe.style.cssText = "white-space:nowrap;font:inherit;letter-spacing:inherit;position:absolute;visibility:hidden";
    probe.innerHTML = el.innerHTML; el.appendChild(probe);
    while (probe.getBoundingClientRect().width / 0.5 > w && n < 30) { fs -= 0.5; el.style.fontSize = fs + "px"; n++; }
    el.removeChild(probe);
    el.setAttribute("data-fitted", fs);
  });
}
document.fonts.ready.then(function () { fitAll(); });
