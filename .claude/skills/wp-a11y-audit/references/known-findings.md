# Known findings & fixes (podcast-local, baseline 2026-07)

The issues found on this site and the fix that resolved each. Fixes are DB-resident and exported to
[`accessibility-fixes/`](../../../../accessibility-fixes/) (Customizer CSS block + Code Snippets export +
README/APPLY-TO-LIVE). Applied and verified on live: home + episode + archive + WPForms pages =
**0 axe violations, 0 W3C errors**.

## Fixed
| # | Issue | WCAG | Fix & layer |
|---|-------|------|-------------|
| 1 | Download / "Play in new window" links distinguished by colour only | 1.4.1 | Customizer CSS — underline, at Sydney's `:root .site :where(a…)` specificity + `!important` |
| 2 | Subscribe/Share inputs labelled by `title` only | 3.3.2 / 4.1.2 | Code Snippet (footer JS) — mirror `title`→`aria-label` |
| 3 | `aria-label` on a role-less `<div>` (`.player-panel-row`) | 4.1.2 | Code Snippet (server-side output buffer) — strip the attribute |
| 4 | Heading order skips `h1`→`h3` (`ssp-episode-title`) | 1.3.1 | Code Snippet (server-side) — rewrite `<h3>`→`<h2>` |
| 5 | Multiple unlabeled `<nav>` landmarks | 1.3.1 | Code Snippet (footer JS) — unique `aria-label`s |
| 6 | Bare `<aside>` = misplaced complementary landmark | 1.3.1 | Code Snippet (footer JS) — `role="presentation"` |
| 7 | Player custom **dark** colours → dark-on-dark input (1.56:1) + missing-stylesheet 404 | 1.4.3 | Disable SSP "Custom Player Colors" → accessible light theme, 404 gone |
| 8 | ~89 invalid CSS declarations (`color:;`, `letter-spacing:px;`, `font-weight:regular`) | (W3C/CSS) | Code Snippet — `sydney_custom_css` filter strips empty/invalid declarations |
| 9 | HTML-validity: share-URL spaces, `readonly` on button, `on="tap:"`, embed `<input>` newlines, stray `</p>`, `<style>`-in-`<div>` (SSP + WPForms var blocks) | (W3C/HTML) | Code Snippet — output buffer: encode/strip/relocate |
| ★ | Pre-existing unclosed `@media (max-width:1024px)` brace in Customizer CSS | — | Added the missing `}` |

## Documented false positives (left as-is)
- Player **contrast** "needs review" (gradient background — real ratio passes).
- WPForms **anti-spam honeypot** hidden field (WAVE flag; `aria-hidden` + `tabindex="-1"`).

## The 4 Code Snippets (in `accessibility-fixes/code-snippets-export.json`)
1. *Accessibility: landmarks, labels & ARIA (a11y pass)* — footer JS (#2, #5, #6)
2. *Accessibility: server-side markup fixes (W3C)* — output buffer (#3, #4)
3. *Sydney: strip empty CSS declarations (W3C)* — `sydney_custom_css` filter (#8)
4. *Sydney: HTML validity fixes (W3C)* — output buffer (#9)

## Gotchas learned
- Sydney resets links with `:root .site :where(a…){text-decoration:none !important}` (0,2,0) — overrides
  must match that specificity + `!important`.
- The Customizer CSS had an unclosed `@media` brace that silently trapped later rules — always
  brace-balance-check before assuming an appended rule applies.
- Code Snippets **free** runs PHP only (CSS/JS-type snippets are Pro/inert) — deliver via PHP snippets.
- Full detail lives in the `sydney-css-a11y-overrides` project memory.
