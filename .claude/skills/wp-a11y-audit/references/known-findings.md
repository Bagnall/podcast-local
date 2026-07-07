# Known findings & fixes (podcast-local, baseline 2026-07)

The issues found on this site and the fix that resolved each. Fixes are DB-resident and exported to
[`accessibility-fixes/`](../../../../accessibility-fixes/) (Customizer CSS block + Code Snippets export +
README/APPLY-TO-LIVE). Applied and verified on live: home + episode + archive + WPForms pages =
**0 axe violations, 0 W3C errors**.

**Full-site sweep (2026-07-06):** every page on the sitemap (26 URLs — all static pages, all 10 episodes,
all 3 series taxonomy pages) checked with axe + custom DOM checks. Result: 0 redundant titles anywhere;
all redundant-link instances correctly `aria-hidden`; the Episode List page (`/podcast/`) had two
genuinely new violations (fixed, #12 below); `/sample-page/` (WordPress's unedited default placeholder,
unlinked from navigation) was deleted rather than remediated. Every remaining flag across the site is
now either fixed or documented below.

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
| 10 | Redundant title text — `title` duplicating the element's own accessible name (aria-label, own text, own `alt`, or a child `img alt`). Found on: header logo link (desktop+mobile), Subscribe/Share `<button>`s, Facebook/Twitter share-icon links, RSS/Episode-URL/Embed-code `<input>`s (whose `aria-label` was mirrored from `title` by fix #2, leaving `title` redundant), and podcast-artwork `<img>` tags | (WAVE alert) | Code Snippet (footer JS) — strip `title` from `a`/`button`/`input`/`img` when it exactly matches the element's own accessible name. Site-wide sweep (2026-07-06) confirms **0 remaining** across all 26 pages |
| 11 | Redundant link — episode-list items link the same URL twice adjacently (image-only link + text-title link); confirmed on 4 pages (home + 3 series taxonomy pages) once images were present for every episode | (WAVE alert) | Code Snippet (footer JS) — `aria-hidden="true" tabindex="-1"` on the image-only link when a sibling link in the same `li`/`article` shares its `href` and text/alt. **Real barrier removed** (axe: 0 violations; link excluded from the accessibility tree and tab order) — but WAVE keeps flagging it anyway; see false positive #4 below |
| 12 | Episode List page (`/podcast/`) only: `landmark-unique` + `landmark-complementary-is-top-level` — this page renders one full player per episode (unlike other listing pages), so SSP's hardcoded `aria-label="Podcast player"` / `"Podcast subscribe and share"` collide across instances, and 6 sidebar widget `<aside>`s nest inside the `#secondary` complementary region | 1.3.1 / 4.1.2 | Code Snippet (footer JS, extends fix #5/#6's snippet) — when 2+ elements share a landmark role + identical label, append that instance's episode title (or a 1-based index) to make each unique; broadened the existing aside→`role="presentation"` selector to include `#secondary aside` |
| 13 | W3C info/warning, site-wide: redundant `type="text/javascript"` on CookieYes's injected `<script>` tag; redundant `role="main"` on `<main id="main">` (already implicit in HTML5); trailing slash on 48 self-closing void elements (`<meta … />`, `<link … />`, etc. — no effect in HTML5, purely noise) | (W3C info/warning) | Code Snippet (server-side output buffer, extends fix #9's snippet) — strip the redundant `type` attr from `<script>` tags, strip `role="main"` from `<main>`, and strip the trailing `/` from any void element's self-closing form. Verified **0 W3C messages of any kind** (not just 0 errors) across all 25 pages checked |
| 14 | Castos player seek/progress bar (`.ssp-progress`) had no `tabindex`, so it could never receive keyboard focus at all — play/pause worked via the real `.play-btn` `<button>`, but seeking was mouse-only | 2.1.1 (Keyboard) | Code Snippet (footer JS, extends fix #5/#6/#12's snippet) — set `role="slider"` + `tabindex="0"` + `aria-label="Seek"`. Turns out SSP's own `castos-player.min.js` **already contains ArrowLeft/ArrowRight keydown handling** for this element — it was dead code because the div could never be focused. No custom seek logic needed; making it focusable was the whole fix. Verified: a single ArrowRight press now correctly advances `audio.currentTime` (confirmed via a property-setter spy, no double-seeking), on both single-episode pages and all 9 players on the Episode List page |
| 15 | Cloudflare Turnstile rollout (2026-07-07, replacing the honeypot on `/register-for-updates/`): WPForms prints a hidden validation-relay `<input class="wpforms-recaptcha-hidden">` that its own JS populates once the CAPTCHA passes (gates client-side submission). It's visually clipped (1px, `clip:rect`) but **not** `aria-hidden`, so axe flags a critical `label` violation — a screen reader lands on an unlabeled, meaningless text field | 4.1.2 / 1.3.1 | Code Snippet (footer JS, extends fix #5/#6/#12/#14's snippet) — `aria-hidden="true" tabindex="-1"` on `.wpforms-recaptcha-hidden`, the same treatment as the honeypot it replaced. Verified 0 axe violations, 0 W3C messages, on both local and live |

## Documented false positives (left as-is)
1. Player **contrast** "needs review" (gradient background — real ratio passes).
2. ~~WPForms **anti-spam honeypot** hidden field~~ — **removed 2026-07-07**, replaced by Cloudflare Turnstile per the site owner's manager's request. See fix #15 for the new gap this introduced (now fixed) and the `accessibility-fixes/README.md` "Cloudflare Turnstile rollout" section for the full writeup.
3. **Hidden HTML5 audio** (WAVE alert, 2026-07-06) — SSP's Castos player hides its native `<audio class="clip-NNN">` and drives playback through a fully custom, accessible control skin (`<button aria-label="Play Episode" aria-pressed="false">` + a progress bar, now also keyboard-seekable — see fix #14). axe reports 0 violations for it; un-hiding it would only add a redundant, unstyled second player.
4. **Redundant link on episode thumbnails** (WAVE alert, persists after fix #11) — the image-only link is `aria-hidden="true" tabindex="-1"`, confirmed removed from the accessibility tree and tab order, and axe reports 0 violations. WAVE flags `aria-hidden` content in its Alerts category regardless of whether it's correctly hidden — same behavior as the (now-removed) honeypot. A more invasive fix (merging the image+title into a single wrapping link, server-side) could make WAVE itself show 0, but wasn't judged worth the extra markup surgery given the real barrier is already gone.
5. **Skip-link not contained in a landmark** (axe `region`, moderate, present site-wide) — Sydney places `<a class="skip-link">Skip to content</a>` before the header, deliberately outside any landmark, so it's the very first focusable element on the page. This is a conventional, widely-used skip-link pattern; accepted as-is rather than fixed.
6. **CookieYes "Consent Preferences" revisit button** (axe `aria-valid-attr-value`, incomplete) — `aria-controls="ckyPreferenceCenter"` references a dialog CookieYes only renders into the DOM when opened. Pre-existing CookieYes behavior, unrelated to any fix in this document; surfaced incidentally while verifying the Turnstile rollout. Not actioned.

## The 5 Code Snippets (in `accessibility-fixes/code-snippets-export.json`)
1. *Accessibility: landmarks, labels & ARIA (a11y pass)* — footer JS (#2, #5, #6, #12, #14, #15)
2. *Accessibility: server-side markup fixes (W3C)* — output buffer (#3, #4)
3. *Sydney: strip empty CSS declarations (W3C)* — `sydney_custom_css` filter (#8)
4. *Sydney: HTML validity fixes (W3C)* — output buffer (#9, #13)
5. *Accessibility: redundant link & title cleanup (WAVE)* — footer JS (#10, #11)

## Gotchas learned
- Sydney resets links with `:root .site :where(a…){text-decoration:none !important}` (0,2,0) — overrides
  must match that specificity + `!important`.
- The Customizer CSS had an unclosed `@media` brace that silently trapped later rules — always
  brace-balance-check before assuming an appended rule applies.
- Code Snippets **free** runs PHP only (CSS/JS-type snippets are Pro/inert) — deliver via PHP snippets.
- Full detail lives in the `sydney-css-a11y-overrides` project memory.
