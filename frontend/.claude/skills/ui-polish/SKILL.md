---
name: ui-polish
description: Restyle Cabinet Médical (Angular PWA) screens like a professional product designer — modern, clean, mobile-first, light theme only — by editing SCSS only, never page content. Use when the user asks to improve the design, look, colors, spacing, polish, "make it modern/professional", restyle a page or component, or when a new page needs styling consistent with the rest of the app.
---

# UI polish — Cabinet Médical design system

You are acting as a senior product designer who also writes production SCSS.
The goal is a calm, trustworthy, modern medical app: generous whitespace, clear
hierarchy, soft depth, one confident accent color (teal), and every tap target
comfortable on a phone.

## Hard rules (never break)

1. **Do not change content.** No edits to `.html` templates or `.ts` files unless
   the user explicitly allows it. No adding/removing/renaming text, labels, icons,
   elements, routes or class names. Style only what already exists, using the
   existing selectors.
2. **Light theme only.** No dark mode, no `prefers-color-scheme` blocks.
3. **Tokens, not literals.** Every color, radius, shadow and font size comes from
   `src/app/shared/styles/_variables.scss`. A hex value in a component file is a
   bug — add a token instead.
4. **Reuse mixins.** Shared patterns live in `src/app/shared/styles/_mixins.scss`.
   If you write the same block twice, it belongs in a mixin.
5. **Keep behavior.** Don't change layout semantics that JS relies on
   (`position: fixed` FABs/toasts, `overflow` on the shell, chevron rotation
   classes like `.open`, state classes like `.active`, `.rupture`, `.alerte`).
6. **Build must pass.** Run `npx ng build` from `frontend/` at the end and fix
   errors. Report any budget warnings.

## Files

| Purpose | File |
|---|---|
| Tokens (colors, type, radius, shadow, motion) | `src/app/shared/styles/_variables.scss` |
| Reusable patterns | `src/app/shared/styles/_mixins.scss` |
| Auth screens layout (login, register, password) | `src/app/shared/styles/_auth.scss` (`@include auth-layout;`) |
| Global base (font, body, focus, selection, select chevron, motion) | `src/styles.scss` |
| PWA icons generator (teal gradient + white cross, no deps) | `.claude/skills/ui-polish/scripts/make_icons.py <out-dir>` → `public/icons/` |
| Style budgets | `angular.json` → `anyComponentStyle` (10kB warn / 16kB error) |
| App shell + bottom nav | `src/app/shared/layout/shell/` |
| PWA colors | `public/manifest.webmanifest`, `src/index.html` (`theme-color`) |

Component SCSS starts with:
```scss
@use '<relative>/shared/styles/variables' as *;
@use '<relative>/shared/styles/mixins' as *;
```

## Design language

**Color.** Teal `$teal` is the only brand accent: primary buttons, active states,
links, header. Semantic colors are reserved for meaning: `$danger` (rupture,
delete), `$warning` (low stock, "utiliser", pending), `$success`, `$info` (edit).
Tinted backgrounds use the `-light` token with the `-dark` token for text — never
saturated color on saturated color. Page background is `$bg-page`; surfaces are
`$white`.

**Typography (Inter).** Use the scale tokens `$fs-xs … $fs-2xl`. Titles 600–700
with slight negative tracking (`$tracking-tight`); body 400–500; metadata
`$text-muted`/`$text-faint`; small caps-style section labels use
`@include section-label`. Numbers that matter (stock, stats) are large, 700,
`font-variant-numeric: tabular-nums`.

**Spacing.** 4px grid. Page gutter 18px; card padding 16px; gap between cards
10–12px; between sections 20–24px.

**Shape & depth.** Cards `$radius` + `$shadow-card` + 1px `$border-soft` hairline.
Buttons/inputs `$radius-md`. Pills fully rounded. Raised elements (FAB, toast,
sheet) use `$shadow-raised`. Never use heavy borders and heavy shadows together.

**Motion.** `$ease` and `$dur-fast/$dur` only. Tappable things get a subtle
press state (`@include pressable`). `prefers-reduced-motion` is handled globally.

**Touch.** Minimum 44px tap targets; inputs ≥ 16px font (prevents iOS zoom).

## Pattern recipes (use the mixin)

| Pattern | Selector examples | Mixin |
|---|---|---|
| Page host | `:host` | `@include page-host;` |
| Page column | `.page`, `.dash` | `@include page-column;` |
| Teal header | `.topbar` | `@include topbar;` — add `@include header-curve;` on the **last** teal block (the `.topbar`, or `.filters` when a filters strip follows it) |
| Header title / back / pill link | `.name`, `.back`, `.btn-corbeille` | `@include topbar-title;` `@include topbar-icon-btn;` `@include topbar-chip;` |
| Card | `.card`, `*-row`, `*-block` | `@include card;` — add `@include pressable;` if it's a link/button |
| Primary / secondary / outline / danger buttons | | `btn-primary`, `btn-secondary`, `btn-outline`, `btn-danger-soft` |
| Small inline action button | `.btn-voir`, `.btn-edit` | `@include btn-sm;` |
| Square icon button | `.btn-icon` | `@include btn-icon;` |
| Input / select / textarea | | `@include field;` |
| Form label | `label` | `@include field-label;` |
| Status pill | `.pill`, `.role-badge` | `@include pill;` |
| Icon tile (colored square with icon) | `.icon`, `.hist-icon` | `@include icon-tile(38px);` |
| Section heading | `.section-title` | `@include section-label;` |
| Floating action button | `.fab` | `@include fab;` |
| Segmented tabs | `.tab` / `.fournisseur-tabs` | `@include segment;` on `.tab` |
| Empty / loading / error text | `.info`, `.err` | `@include state-text;` |

## Workflow

1. Read the target component's `.html` to learn the real structure (which classes
   exist, nesting, which elements are buttons/links). Never style by guessing.
2. Read its `.scss`. Look for: hardcoded hex values, duplicated blocks, broken
   nesting (a missing `}` that nests unrelated selectors), blocks for classes that
   don't exist in the template (dead code — remove).
3. Rewrite the SCSS with tokens + mixins, keeping **every selector the template
   uses**. Preserve state classes and their meaning.
4. If a token or mixin is missing, add it to the shared files (with a short French
   comment, matching the existing style), not locally.
5. `npx ng build` → fix errors; mention any `anyComponentStyle` budget warnings.
6. Summarize per page what changed visually, not line by line.

## Quality checklist (designer's eye)

- [ ] One clear focal point per screen (title or key number), everything else quieter.
- [ ] Consistent radius, shadow and spacing between pages.
- [ ] Text contrast ≥ 4.5:1 for body (`$text-faint` only for non-essential meta).
- [ ] Every interactive element has hover (desktop), press, focus-visible and disabled states.
- [ ] Danger actions look secondary until confirmed (soft red), never louder than the primary action.
- [ ] Header respects the notch: `padding-top` includes `env(safe-area-inset-top)`; bottom nav includes `env(safe-area-inset-bottom)`.
- [ ] No horizontal scroll at 360px width.
- [ ] No content, wording or markup changed.
