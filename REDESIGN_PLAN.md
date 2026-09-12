# THSC Online — Component Decision Matrix & File-Level Plan

Companion to `DESIGN_SYSTEM.md` and `REDESIGN_PLAN.md`. Scope: static,
GitHub-Pages-compatible, no build step required.

## 1. Component decision matrix (arsenal §27)

| Need | Primary source | Fallback | Copy/adapt | Install | Reject | Why |
|---|---|---|---|---|---|---|
| Buttons/inputs/cards | Hand-written CSS design system | — | — | no | MUI/Ant/Chakra | Owned, no build step, static GitHub Pages |
| Icons | Lucide (CDN, inline SVG) | Heroicons | yes | no | MUI/Ant icon packs | One stroke weight, tree-shakeable |
| Animations | Hand-written CSS keyframes | GSAP CDN | yes | no | Framer Motion | Static site, no build step; CSS covers 100% of needs |
| Fonts | Google Fonts (self-hosted fallback) | system stack | — | no | — | GitHub-Pages compatible |
| Search | Client-side JSON index (built from a sitemap-like crawl) | — | — | no | React | Static site; no server |
| Theme | CSS custom properties + localStorage toggle | — | — | no | — | No build step |

**Decision matrix (arsenal §27):** see `DESIGN_SYSTEM.md` §8 for component inventory.

**Decision (§27):** hand-written CSS design system (owned, no
framework), pulling **Lucide icons via CDN** where needed. React-component registries
don't apply directly — this repo is **plain static HTML/CSS with no build step**,
so React-component registries don't apply directly.

## 2. File-level plan (arsenal §28)

| File | Action | Responsibility |
|---|---|---|
| `index.html` | MODIFY (replace) | New landing page: hero + year shelf + subject grid + footer; semantic HTML, landmarks, breadcrumbs |
| `index-style.css` | REMOVE (replace) | Delete 40KB dead vBulletin stylesheet; replaced by `assets/css/` |
| `assets/css/tokens.css` | CREATE | Design tokens (colors, type, spacing, elevation, motion) |
| `assets/css/base.css` | CREATE | Reset, base typography, focus states, selection |
| `assets/css/components.css` | CREATE | Buttons, inputs, cards, badges, tables, tabs, tooltips, toasts, skeletons |
| `assets/css/landing.css` | CREATE | Hero, year shelf, subject grid, footer |
| `assets/js/theme.js` | CREATE | Theme toggle (dark default, localStorage, auto-detect) |
| `assets/js/search.js` | CREATE | Client-side search over a JSON index |
| `assets/js/motion.js` | CREATE | IntersectionObserver entrances, stagger, reduced-motion guard |
| `DESIGN_SYSTEM.md` | KEEP | Design system doc (already written) |
| `REDESIGN_PLAN.md` | KEEP | Master plan (already written) |

## 3. Testing strategy

- No existing tests in the repo (static site). Preserve that.
- Add: HTML validation (html-validate or tidy), link check (internal links),
  and axe-core (CDN bookmarklet or script) as a manual QA pass.
- New behavior (theme toggle, search) gets a smoke test.

## 4. Browser QA strategy

- Phase 0: baseline screenshots (BEFORE state) — pending; preview server died.
- Phase 1: AFTER screenshots at 375/768/1024/1440.
- Phase 2: dead-interaction audit per §32.
- Phase 3: design-quality scoring per §33 (anything < 8 gets another review).

## 5. Risk register

| Risk | Impact | Mitigation |
|---|---|---|
| /s/ pages are server-side nginx autoindex, not in this repo | High | Scope: redesign root landing page + client-side experience of /s/ where possible; document constraint |
| Broken links to /s/ pages if paths change | Medium | Link check (internal links) after build |
| Fonts blocked (CDN) | Low | font-display: swap + system fallback stack |
| JS disabled | Medium | Site must work without JS (theme default via prefers-color-scheme, content visible without JS) |
| GitHub Pages 404s on trailing-slash paths | Medium | Link check (internal links) after build |

## 6. Rollback strategy

- All new files are **new files** (`assets/css/`, `assets/js/`); `index.html`
  replacement is a single MODIFY. Rollback = `git checkout e4b6289 -- index.html`
  + delete new files. Old `index-style.css` is deleted; keep a copy in git
  history (it is, at e4b6289).
