/* THSC Online — Motion (Phase 4)
   IntersectionObserver staggered reveals. Respects prefers-reduced-motion.

   Markup:
     <div data-reveal>                          single reveal (fade + translateY)
     <div data-stagger>
       <div data-reveal></div> <div data-reveal></div>
     </div>                                     each child reveals, 40ms apart

   The reduced-motion path leaves everything visible (CSS guarantees opacity 1),
   and this script no-ops. */
(function () {
  var REDUCED = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  if (REDUCED || !("IntersectionObserver" in window)) return;

  var STAGGER_MS = 40;

  function reveal(el) {
    el.classList.add("is-revealed");
  }

  function observerFor(handler) {
    var obs = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          handler(entry.target);
          obs.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -8% 0px" });
    return obs;
  }

  function init() {
    // Single reveals
    var singles = document.querySelectorAll("[data-reveal]:not([data-stagger] *)");
    if (singles.length) {
      var obs = observerFor(reveal);
      singles.forEach(function (el) { obs.observe(el); });
    }

    // Staggered groups
    var groups = document.querySelectorAll("[data-stagger]");
    groups.forEach(function (group) {
      var kids = Array.prototype.slice.call(group.querySelectorAll("[data-reveal]"));
      if (!kids.length) return;
      var g = observerFor(function () {
        kids.forEach(function (el, i) {
          setTimeout(function () { reveal(el); }, i * STAGGER_MS);
        });
      });
      g.observe(group);
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    // DOMContentLoaded already fired; an IntersectionObserver still fires
    // for above-the-fold nodes on the next frame, so init directly.
    init();
  }
})();