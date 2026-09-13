/* THSC Online — Inline SVG icons (Phase 1).
   Lucide-style: 24x24 viewBox, 1.5 stroke, currentColor, aria-hidden by default.
   Element usage: <svg class="icon ic-chevron-right" aria-hidden="true"><use href="#ic-chevron-right"/></svg>
   Inject the <defs> sprite once at load; works without JS by falling back to static <svg> paths. */

(function () {
  var ICONS = {
    "book": '<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>',
    "sun": '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
    "moon": '<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/>',
    "search": '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>',
    "chevron-right": '<path d="m9 18 6-6-6-6"/>',
    "folder": '<path d="M4 20h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13c0 1.1.9 2 2 2Z"/>',
    "file": '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/>',
    "external": '<path d="M15 3h6v6"/><path d="M10 14 21 3"/><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/>',
    "arrow-right": '<path d="M5 12h14"/><path d="m12 5 7 7-7 7"/>'
  };

  var NS = "http://www.w3.org/2000/svg";

  function buildSprite() {
    var svg = document.createElementNS(NS, "svg");
    svg.setAttribute("width", "0");
    svg.setAttribute("height", "0");
    svg.setAttribute("style", "position:absolute");
    svg.setAttribute("aria-hidden", "true");
    var defs = document.createElementNS(NS, "defs");
    Object.keys(ICONS).forEach(function (name) {
      var g = document.createElementNS(NS, "g");
      g.setAttribute("id", "ic-" + name);
      g.setAttribute("fill", "none");
      g.setAttribute("stroke", "currentColor");
      g.setAttribute("stroke-width", "1.5");
      g.setAttribute("stroke-linecap", "round");
      g.setAttribute("stroke-linejoin", "round");
      g.innerHTML = ICONS[name];
      defs.appendChild(g);
    });
    svg.appendChild(defs);
    document.body.appendChild(svg);
  }

  // Runtime helper for dynamic DOM: return full inline <svg> for a named icon.
  window.THSCIcon = function (name, className) {
    var svg = document.createElementNS(NS, "svg");
    svg.setAttribute("class", "icon" + (className ? " " + className : ""));
    svg.setAttribute("viewBox", "0 0 24 24");
    svg.setAttribute("width", "20");
    svg.setAttribute("height", "20");
    svg.setAttribute("aria-hidden", "true");
    var use = document.createElementNS(NS, "use");
    use.setAttribute("href", "#ic-" + name);
    svg.appendChild(use);
    return svg;
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", buildSprite);
  } else {
    buildSprite();
  }
})();