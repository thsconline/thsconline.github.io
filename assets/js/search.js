/* THSC Online — Search (Phase 5)
   Client-side search over an embedded index of HSC years and subjects.
   No network: the index is static. Result links point at the live /s/ tree.
   Progressive enhancement: form still works without JS by submitting to /s/. */
(function () {
  var INDEX = [
    { label: "Year 9", group: "Year 9", title: "All subjects", href: "s/yr9/", count: null },
    { label: "Year 10", group: "Year 10", title: "All subjects", href: "s/yr10/", count: null },
    { label: "Year 11", group: "Year 11", title: "All subjects", href: "s/yr11/", count: null },
    { label: "Year 12", group: "Year 12", title: "All subjects", href: "s/yr12/", count: null },
    { label: "English", group: "Year 12", title: "English papers", href: "s/yr12/English/", count: "HSC" },
    { label: "English Advanced", group: "Year 12", title: "English Advanced", href: "s/yr12/English%20Advanced/", count: "HSC" },
    { label: "English Standard", group: "Year 12", title: "English Standard", href: "s/yr12/English%20Standard/", count: "HSC" },
    { label: "Mathematics", group: "Year 12", title: "Mathematics", href: "s/yr12/Mathematics/", count: "HSC" },
    { label: "Mathematics Advanced", group: "Year 12", title: "Mathematics Advanced", href: "s/yr12/Mathematics%20Advanced/", count: "HSC" },
    { label: "Chemistry", group: "Year 12", title: "Chemistry", href: "s/yr12/Chemistry/", count: "HSC" },
    { label: "Physics", group: "Year 12", title: "Physics", href: "s/yr12/Physics/", count: "HSC" },
    { label: "Biology", group: "Year 12", title: "Biology", href: "s/yr12/Biology/", count: "HSC" },
    { label: "Economics", group: "Year 12", title: "Economics", href: "s/yr12/Economics/", count: "HSC" },
    { label: "Legal Studies", group: "Year 12", title: "Legal Studies", href: "s/yr12/Legal%20Studies/", count: "HSC" },
    { label: "Business Studies", group: "Year 12", title: "Business Studies", href: "s/yr12/Business%20Studies/", count: "HSC" },
    { label: "Ancient History", group: "Year 12", title: "Ancient History", href: "s/yr12/Ancient%20History/", count: "HSC" },
    { label: "Modern History", group: "Year 12", title: "Modern History", href: "s/yr12/Modern%20History/", count: "HSC" },
    { label: "Geography", group: "Year 12", title: "Geography", href: "s/yr12/Geography/", count: "HSC" },
    { label: "Chinese", group: "Year 12", title: "Chinese", href: "s/yr12/Chinese/", count: "HSC" }
  ];

  function esc(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
  }

  function normalize(s) { return s.toLowerCase().replace(/[^a-z0-9]+/g, " ").trim(); }

  function search(q) {
    var nq = normalize(q);
    if (!nq) return [];
    return INDEX.filter(function (item) {
      var hay = normalize(item.label + " " + item.group + " " + item.title);
      return nq.split(/\s+/).every(function (tok) { return hay.indexOf(tok) !== -1; });
    }).slice(0, 8);
  }

  function init() {
    var form = document.querySelector("[data-search]");
    if (!form) return;
    var input = form.querySelector("input[name='q']");
    var list = form.querySelector(".search-results");
    if (!input || !list) return;

    input.setAttribute("autocomplete", "off");
    input.setAttribute("role", "combobox");
    input.setAttribute("aria-autocomplete", "list");
    input.setAttribute("aria-expanded", "false");
    input.setAttribute("aria-controls", list.id || "search-results");
    if (!list.id) list.id = "search-results";

    function render(q) {
      var results = search(q);
      list.textContent = "";
      if (!q.trim()) { list.setAttribute("data-open", "false"); input.setAttribute("aria-expanded", "false"); return; }

      if (!results.length) {
        var empty = document.createElement("div");
        empty.className = "search-empty";
        empty.textContent = 'No match. Try a subject, e.g. "Chemistry".';
        list.appendChild(empty);
      } else {
        results.forEach(function (r) {
          var a = document.createElement("a");
          a.className = "search-result";
          a.href = r.href;
          a.innerHTML =
            '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true" width="16" height="16"><use href="#ic-folder"/></svg>' +
            "<span><strong>" + esc(r.label) + "</strong> &middot; " + esc(r.title) + "</span>" +
            (r.count ? '<span class="sr-meta">' + esc(r.count) + "</span>" : "");
          list.appendChild(a);
        });
      }
      list.setAttribute("data-open", "true");
      input.setAttribute("aria-expanded", "true");
    }

    input.addEventListener("input", function () { render(input.value); });
    input.addEventListener("keydown", function (e) {
      if (e.key === "Escape") { list.setAttribute("data-open", "false"); input.setAttribute("aria-expanded", "false"); input.blur(); }
      if (e.key === "Enter") { /* allow default form submit to /s/ search */ }
    });
    document.addEventListener("click", function (e) {
      if (!form.contains(e.target)) { list.setAttribute("data-open", "false"); input.setAttribute("aria-expanded", "false"); }
    });
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();