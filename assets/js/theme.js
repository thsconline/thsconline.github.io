/* THSC Online — Theme system (Phase 0)
   Dark-first default. Auto-detect via prefers-color-scheme,
   manual override persisted to localStorage. Executes eagerly to avoid FOUC. */

(function () {
  var STORAGE_KEY = "thsconline-theme";

  function getPreferredTheme() {
    try {
      var saved = window.localStorage.getItem(STORAGE_KEY);
      if (saved === "dark" || saved === "light") return saved;
    } catch (e) { /* storage unavailable */ }
    return window.matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark";
  }

  var theme = getPreferredTheme();
  document.documentElement.setAttribute("data-theme", theme);

  window.THSCTheme = {
    current: theme,
    toggle: function () {
      var next = document.documentElement.getAttribute("data-theme") === "light" ? "dark" : "light";
      document.documentElement.setAttribute("data-theme", next);
      try { window.localStorage.setItem(STORAGE_KEY, next); } catch (e) {}
      this.current = next;
      var btn = document.querySelector("[data-theme-toggle]");
      if (btn) {
        btn.setAttribute("aria-label", next === "dark" ? "Switch to light theme" : "Switch to dark theme");
      }
      return next;
    }
  };
})();