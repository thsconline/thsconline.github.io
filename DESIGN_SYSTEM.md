# THSC Online — Design System (Phase 0)

Derived from: `frontend-design` + `ui-ux-pro-max` skills, arsenal prompt sections 8–12, and the
subject world: a public archive of NSW HSC practice papers. Emotion target: **calm confidence** —
a reference desk, not a dashboard.

## 1. Design direction (frontend-design skill pass)

Subject grounding: students and teachers looking for past exam papers. The page's single job:
**get from "I have a subject" to "I have the PDF" in under 10 seconds.**

- **Signature element**: the "shelf" — a horizontally scrolling row of year cards
  (Year 9 → Year 12) styled like library spines, each with a paper-count stat. This is the
  one memorable element; everything else stays quiet and disciplined.
- **Emotion**: calm confidence. This is a reference desk, not a dashboard. No gamification,
  no neon, no particle spam.
- **Aesthetic risk (the one justified risk)**: an oversized display headline set in a
  high-contrast serif, oversized enough to feel like a printed exam cover — one real
  aesthetic risk, spent in exactly one place (the hero headline).

Calibration note (from frontend-design skill): avoid the three AI-default looks —
warm-cream + serif + terracotta; near-black + single acid-green; broadsheet hairline rules.
The chosen direction (deep ink dark + indigo accent + oversized serif hero) is a deliberate
choice for this subject, not a default.

## 2. Color tokens (semantic, dark-first)

Dark-first theme; light theme ships as a polished alternative. Auto-detect via
`prefers-color-scheme`, manual toggle persisted to `localStorage`.

| Token | Dark | Light |
|---|---|---|
| `--bg` | `#0B0D12` | `#F8FAFC` |
| `--surface` | `#12151D` | `#FFFFFF` |
| `--surface-2` (elevated) | `#1A1F2B` | `#FFFFFF` |
| `--popover` | `#1A1F2B` | `#FFFFFF` |
| `--border` | `rgba(255,255,255,0.08)` | `#E4E5E7` |
| `--fg` | `#EDEDEF` | `#0F172A` |
| `--fg-muted` | `#8A8F98` | `#5B6472` |
| `--primary` | `#5E6AD2` (indigo) | `#4F5BD5` |
| `--on-primary` | `#FFFFFF` | `#FFFFFF` |
| `--success` | `#34D399` | `#059669` |
| `--warning` | `#FBBF24` | `#D97706` |
| `--destructive` | `#F87171` | `#DC2626` |
| `--info` | `#60A5FA` | `#2563EB` |
| `--focus` | `#8B93F8` | `#4F5BD5` |
| `--selection` | `rgba(94,106,210,0.35)` | `rgba(79,91,213,0.25)` |

Contrast targets (verified numerically at build time, not by eye):
- Body text on `--bg`: ≥ 4.5:1 (dark: `#EDEDEF` on `#0B0D12` ≈ 15.9:1 ✓; light: `#0F172A` on `#F8FAFC` ≈ 16.1:1 ✓)
- Muted text: ≥ 3:1 (dark: `#8A8F98` on `#0B0D12` ≈ 4.6:1 ✓)
- Accent on surface: `#5E6AD2` on `#12151D` ≈ 3.6:1 — used for borders/glows and large text only; interactive accent text uses `#8B93F8` (≈ 6.2:1 ✓)
- Primary button: `#FFFFFF` on `#5E6AD2` ≈ 5.6:1 ✓

Dark-mode rule (ui-ux-pro-max §6): dark surfaces use **desaturated tonal variants**, not
inverted colors; each theme's contrast pairs are verified separately, never inferred.

## 3. Typography system

| Role | Face | Size / notes |
|---|---|---|
| Display / hero | **Fraunces** (high-contrast serif, `SOFT`/`WONK` axes) | `clamp(2.75rem, 8vw, 5.5rem)`, weight 600, tracking −0.02em; the one oversized statement |
| Page title | Fraunces 500 | `clamp(1.75rem, 4vw, 2.5rem)` |
| Section title | Inter 600 | `1.125rem` / 1.4 |
| Card title | Inter 600 | `1rem` |
| Body | Inter 400 | `0.9375rem` / 1.6, max 70ch |
| Secondary text | Inter 400 | `0.875rem`, `--fg-muted` |
| Metadata / labels | Inter 500 uppercase | `0.6875rem`, tracking 0.08em |
| Numeric values | Inter, `font-variant-numeric: tabular-nums` | paper counts, dates, sizes |
| Code / filenames | JetBrains Mono 400 | `0.8125rem` |

Type scale (rem): 0.6875 / 0.8125 / 0.875 / 0.9375 / 1.125 / 1.5 / 1.75 / 2.5 / 2.75–5.5 (clamp).
Body line-height 1.6; headings 1.2. Line length ≤ 70ch.

The oversized serif hero headline is the **one** typographic risk; everything else is quiet
Inter with tabular numerals for the paper lists.

## 4. Spacing system

4/8pt scale: `4 / 8 / 12 / 16 / 24 / 32 / 48 / 64 / 96`. Section rhythm tiers: 24 (card groups)
/ 32 (page sections) / 48 (page header → content) / 64 (hero block padding).

| Context | Value |
|---|---|
| Page horizontal padding | `clamp(1rem, 4vw, 2rem)` |
| Container max-width | `72rem` (1152px) |
| Grid gaps | `16` (cards) / `12` (dense lists) |
| Card padding | `16` mobile / `24` desktop |
| Section spacing | `32` / `48` (page header → content) |
| Hero block padding | `64` top, `96` bottom |

## 5. Surface / elevation system

| Level | Dark | Use |
|---|---|---|
| base | `--bg` | page canvas |
| surface | `--surface` | cards, rows |
| elevated | `--surface-2` | hover-raised cards, dropdowns |
| popover | `--popover` | menus, autocomplete |
| overlay | `rgba(0,0,0,0.55)` scrim | modal backdrop |

Dark-mode elevation = **lighter surface, not bigger shadow** (atmos.style/Material dark-theme
practice). Shadows are subtle (`0 1px 2px rgba(0,0,0,0.4)`); accent glows appear **only** on
the primary CTA and the hero headline — rare by design. Border `rgba(255,255,255,0.08)`
hairlines carry most separation; consistent `--radius` scale: 8 (inputs) / 10 (cards) / 999 (pills).

## 6. Motion language (single rhythm, shared tokens)

| Token | Duration | Easing | Use |
|---|---|---|---|
| `--dur-instant` | 0ms | — | state flags |
| `--dur-micro` | 120ms | ease-out | hover, focus ring |
| `--dur-short` | 200ms | ease-out | enter, dropdowns |
| `--dur-medium` | 280ms | cubic-bezier(0.16,1,0.3,1) | page/section entrance |
| `--dur-exit` | 140ms | ease-in | exits (~60% of enter) |

- Entrance: opacity 0→1 + translateY 8px→0, staggered **40ms** per item (list/grid), max 6 items visible
- Hover: translateY(−2px) + border-color shift + shadow lift on cards (transform/opacity only)
- Press: scale 0.97 on tappable cards/buttons, restored on release
- Interruptible: user interaction cancels in-progress animation immediately; no blocking animation
- Direction: forward nav enters from below, backward exits upward
- All animations on `transform`/`opacity` only; unified tokens globally
- **`prefers-reduced-motion: reduce`** → all entrances/hovers collapse to opacity-only crossfade, no translateY/scale, no autonomous animation

## 7. Iconography

One system: **Lucide** (inline SVG, 1.5px stroke), sizes 16/20/24 as tokens. Decorative icons
`aria-hidden="true"`; functional icon-only controls get `aria-label`.

## 8. Component inventory (Phase 2 scope)

Button (primary/secondary/ghost, all 8 states), Input + label, Select, Card, Badge (year/subject),
Table row (paper list), Tabs, Tooltip, Breadcrumb, Toast (aria-live="polite"), Skeleton loader.
Ownership: every primitive lives in `assets/css/` once, referenced everywhere — no per-page hex.
