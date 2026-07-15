# Known findings & fixes (podcast-local, baseline 2026-07)

The issues found on this site and the fix that resolved each. Fixes are DB-resident and exported to
[`accessibility-fixes/`](../../../../accessibility-fixes/) (Customizer CSS block + Code Snippets export +
README/APPLY-TO-LIVE). Applied and verified on live: home + episode + archive + WPForms pages =
**0 axe violations, 0 W3C errors**.

**SSP 3.16.3 upgrade (2026-07-15):** Seriously Simple Podcasting 3.16.3 (released 2026-07-13, acting on a
bug report we filed) fixed several things natively that our snippets were patching. Local was updated
3.16.2 → 3.16.3 and re-verified (0 axe violations, 0 W3C errors, snippet #2's snippet disabled during the
check). Net changes:
- **Fixes #3 and #4 are now handled upstream** → the *"Accessibility: server-side markup fixes (W3C)"*
  snippet was **deleted** (5 snippets → 4). SSP now emits `role="group"` on `.player-panel-row` (so the
  `aria-label` is valid — #3) and a configurable `$title_level` defaulting to `h2` on episode-list titles
  (so no `h1→h3` skip — #4).
- **Fixes #9's `readonly`-on-`<button>` and embed-`<input>`-newline passes are now moot** — SSP removed the
  invalid `readonly` and changed the Embed field from `<input>` to `<textarea>`. The other #9/#13 passes
  (Sydney/CookieYes) still apply, so that snippet stays; the two dead passes are left in place, harmless.
- **New regression the upgrade introduced, fixed:** the Embed field becoming a `<textarea>` slipped past
  fixes #2 and #10 (their selectors only matched `input`), producing a `label-title-only` violation. Both
  snippets were broadened to also cover `textarea[title]`.

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
| 2 | Subscribe/Share inputs labelled by `title` only | 3.3.2 / 4.1.2 | Code Snippet (footer JS) — mirror `title`→`aria-label`. **Broadened 2026-07-15** to cover `textarea` too (SSP 3.16.3 made the Embed field a `<textarea>`) |
| 3 | `aria-label` on a role-less `<div>` (`.player-panel-row`) | 4.1.2 | ~~Code Snippet (server-side output buffer) — strip the attribute~~ **RETIRED 2026-07-15 — fixed upstream in SSP 3.16.3** (the div now carries `role="group"`, making the `aria-label` valid). Snippet deleted |
| 4 | Heading order skips `h1`→`h3` (`ssp-episode-title`) | 1.3.1 | ~~Code Snippet (server-side) — rewrite `<h3>`→`<h2>`~~ **RETIRED 2026-07-15 — fixed upstream in SSP 3.16.3** (episode-list titles now use a configurable `$title_level`, default `h2`). Snippet deleted |
| 5 | Multiple unlabeled `<nav>` landmarks | 1.3.1 | Code Snippet (footer JS) — unique `aria-label`s |
| 6 | Bare `<aside>` = misplaced complementary landmark | 1.3.1 | Code Snippet (footer JS) — `role="presentation"` |
| 7 | Player custom **dark** colours → dark-on-dark input (1.56:1) + missing-stylesheet 404 | 1.4.3 | Disable SSP "Custom Player Colors" → accessible light theme, 404 gone |
| 8 | ~89 invalid CSS declarations (`color:;`, `letter-spacing:px;`, `font-weight:regular`) | (W3C/CSS) | Code Snippet — `sydney_custom_css` filter strips empty/invalid declarations |
| 9 | HTML-validity: share-URL spaces, `readonly` on button, `on="tap:"`, embed `<input>` newlines, stray `</p>`, `<style>`-in-`<div>` (SSP + WPForms var blocks) | (W3C/HTML) | Code Snippet — output buffer: encode/strip/relocate. **Note (2026-07-15):** the `readonly`-on-`<button>` and embed-`<input>`-newline passes are now moot — SSP 3.16.3 removed the invalid `readonly` and made the Embed field a `<textarea>`. The other passes (Sydney/CookieYes) still apply; snippet kept, two passes now inert |
| ★ | Pre-existing unclosed `@media (max-width:1024px)` brace in Customizer CSS | — | Added the missing `}` |
| 10 | Redundant title text — `title` duplicating the element's own accessible name (aria-label, own text, own `alt`, or a child `img alt`). Found on: header logo link (desktop+mobile), Subscribe/Share `<button>`s, Facebook/Twitter share-icon links, RSS/Episode-URL/Embed-code `<input>`s (whose `aria-label` was mirrored from `title` by fix #2, leaving `title` redundant), and podcast-artwork `<img>` tags | (WAVE alert) | Code Snippet (footer JS) — strip `title` from `a`/`button`/`input`/`textarea`/`img` when it exactly matches the element's own accessible name (`textarea` added 2026-07-15 for SSP 3.16.3's Embed field). Site-wide sweep (2026-07-06) confirms **0 remaining** across all 26 pages |
| 11 | Redundant link — episode-list items link the same URL twice adjacently (image-only link + text-title link); confirmed on 4 pages (home + 3 series taxonomy pages) once images were present for every episode | (WAVE alert) | Code Snippet (footer JS) — `aria-hidden="true" tabindex="-1"` on the image-only link when a sibling link in the same `li`/`article` shares its `href` and text/alt. **Real barrier removed** (axe: 0 violations; link excluded from the accessibility tree and tab order) — but WAVE keeps flagging it anyway; see false positive #4 below |
| 12 | Episode List page (`/podcast/`) only: `landmark-unique` + `landmark-complementary-is-top-level` — this page renders one full player per episode (unlike other listing pages), so SSP's hardcoded `aria-label="Podcast player"` / `"Podcast subscribe and share"` collide across instances, and 6 sidebar widget `<aside>`s nest inside the `#secondary` complementary region | 1.3.1 / 4.1.2 | Code Snippet (footer JS, extends fix #5/#6's snippet) — when 2+ elements share a landmark role + identical label, append that instance's episode title (or a 1-based index) to make each unique; broadened the existing aside→`role="presentation"` selector to include `#secondary aside` |
| 13 | W3C info/warning, site-wide: redundant `type="text/javascript"` on CookieYes's injected `<script>` tag; redundant `role="main"` on `<main id="main">` (already implicit in HTML5); trailing slash on 48 self-closing void elements (`<meta … />`, `<link … />`, etc. — no effect in HTML5, purely noise) | (W3C info/warning) | Code Snippet (server-side output buffer, extends fix #9's snippet) — strip the redundant `type` attr from `<script>` tags, strip `role="main"` from `<main>`, and strip the trailing `/` from any void element's self-closing form. Verified **0 W3C messages of any kind** (not just 0 errors) across all 25 pages checked |
| 14 | Castos player seek/progress bar (`.ssp-progress`) had no `tabindex`, so it could never receive keyboard focus at all — play/pause worked via the real `.play-btn` `<button>`, but seeking was mouse-only | 2.1.1 (Keyboard) | Code Snippet (footer JS, extends fix #5/#6/#12's snippet) — set `role="slider"` + `tabindex="0"` + `aria-label="Seek"`. Turns out SSP's own `castos-player.min.js` **already contains ArrowLeft/ArrowRight keydown handling** for this element — it was dead code because the div could never be focused. No custom seek logic needed; making it focusable was the whole fix. Verified: a single ArrowRight press now correctly advances `audio.currentTime` (confirmed via a property-setter spy, no double-seeking), on both single-episode pages and all 9 players on the Episode List page |
| 15 | Cloudflare Turnstile rollout (2026-07-07, replacing the honeypot on `/register-for-updates/`): WPForms prints a hidden validation-relay `<input class="wpforms-recaptcha-hidden">` that its own JS populates once the CAPTCHA passes (gates client-side submission). It's visually clipped (1px, `clip:rect`) but **not** `aria-hidden`, so axe flags a critical `label` violation — a screen reader lands on an unlabeled, meaningless text field | 4.1.2 / 1.3.1 | Code Snippet (footer JS, extends fix #5/#6/#12/#14's snippet) — `aria-hidden="true" tabindex="-1"` on `.wpforms-recaptcha-hidden`, the same treatment as the honeypot it replaced. Verified 0 axe violations, 0 W3C messages, on both local and live |
| 16 | `region` (best-practice, moderate, site-wide): Sydney's skip-link (`<a class="skip-link">Skip to content`) sits before the header, outside every landmark, so axe reports "all page content not contained by landmarks". **Previously accepted as false positive #5** — re-opened 2026-07-15 and fixed, since it's genuinely resolvable and the site owner wants clean reports | 1.3.1 (best-practice) | Code Snippet (footer JS, extends fix #5/#6/#12/#14/#15's snippet) — wrap the skip-link in a labelled `<nav aria-label="Skip links">`. **Empirically, wrapping is the only fix that works**: `tabindex="-1"` on the target, re-pointing the `href` to the `<main>` landmark, and `role="region"` on the target were all tested and axe still flagged it. Guarded/idempotent (skips if already inside a nav). Verified 0 violations on local; live needs the updated snippet (APPLY-TO-LIVE Part 7) |

## Documented false positives (left as-is)
1. Player **contrast** "needs review" (gradient background — real ratio passes).
2. ~~WPForms **anti-spam honeypot** hidden field~~ — **removed 2026-07-07**, replaced by Cloudflare Turnstile per the site owner's manager's request. See fix #15 for the new gap this introduced (now fixed) and the `accessibility-fixes/README.md` "Cloudflare Turnstile rollout" section for the full writeup.
3. **Hidden HTML5 audio** (WAVE alert, 2026-07-06) — SSP's Castos player hides its native `<audio class="clip-NNN">` and drives playback through a fully custom, accessible control skin (`<button aria-label="Play Episode" aria-pressed="false">` + a progress bar, now also keyboard-seekable — see fix #14). axe reports 0 violations for it; un-hiding it would only add a redundant, unstyled second player.
4. **Redundant link on episode thumbnails** (WAVE alert, persists after fix #11) — the image-only link is `aria-hidden="true" tabindex="-1"`, confirmed removed from the accessibility tree and tab order, and axe reports 0 violations. WAVE flags `aria-hidden` content in its Alerts category regardless of whether it's correctly hidden — same behavior as the (now-removed) honeypot. A more invasive fix (merging the image+title into a single wrapping link, server-side) could make WAVE itself show 0, but wasn't judged worth the extra markup surgery given the real barrier is already gone.
5. ~~**Skip-link not contained in a landmark** (axe `region`, moderate, present site-wide)~~ — **RE-OPENED & FIXED 2026-07-15, now fix #16.** Originally accepted as a conventional pattern, but it's cleanly resolvable (wrap in a labelled `<nav>`) and the site owner wants clean axe reports, so it was fixed rather than accepted. See fix #16.
6. **CookieYes "Consent Preferences" revisit button** (axe `aria-valid-attr-value`, incomplete) — `aria-controls="ckyPreferenceCenter"` references a dialog CookieYes only renders into the DOM when opened. Pre-existing CookieYes behavior, unrelated to any fix in this document; surfaced incidentally while verifying the Turnstile rollout. Not actioned.
7. **Cloudflare Turnstile hidden validation-relay field** (WAVE alert, 2026-07-07, `/register-for-updates/`) — WAVE flags `.wpforms-recaptcha-hidden` (the field fixed in #15) as a hidden field needing review. Re-confirmed on live: the field is correctly `aria-hidden="true" tabindex="-1"`, and axe reports 0 violations for it. Same behavior as false positive #4 (WAVE flags any `aria-hidden` element regardless of correctness) — this is the fourth instance of that exact pattern on this site (honeypot, redundant-link thumbnails, and now this).

## The 4 Code Snippets (in `accessibility-fixes/code-snippets-export.json`)
*(was 5 — "Accessibility: server-side markup fixes (W3C)" (#3, #4) deleted 2026-07-15, fixed upstream in SSP 3.16.3.)*
1. *Accessibility: landmarks, labels & ARIA (a11y pass)* — footer JS (#2, #5, #6, #12, #14, #15, #16)
2. *Sydney: strip empty CSS declarations (W3C)* — `sydney_custom_css` filter (#8)
3. *Sydney: HTML validity fixes (W3C)* — output buffer (#9, #13)
4. *Accessibility: redundant link & title cleanup (WAVE)* — footer JS (#10, #11)

## Gotchas learned
- Sydney resets links with `:root .site :where(a…){text-decoration:none !important}` (0,2,0) — overrides
  must match that specificity + `!important`.
- The Customizer CSS had an unclosed `@media` brace that silently trapped later rules — always
  brace-balance-check before assuming an appended rule applies.
- Code Snippets **free** runs PHP only (CSS/JS-type snippets are Pro/inert) — deliver via PHP snippets.
- **axe timing vs. Sydney's preloader (learned 2026-07-15):** Sydney shows a full-screen `.preloader`
  overlay that JS removes shortly after load. While it's still up, axe's `region` rule returns **0**
  (a false *negative*); once it's gone (steady state, what a real user/axe-DevTools sees) the skip-link
  `region` flag appears. **Always audit at `networkidle` / after `.preloader` has the `disable` class
  and is hidden**, or you'll miss `region` (and possibly other visibility-dependent) findings. Earlier
  audits that reported "0 region" were run mid-preload and were false negatives.
- The `region` skip-link fix: axe only clears it when the skip-link is *inside* a landmark — wrapping in
  `<nav>` works; `tabindex`/`role`/re-pointing the href on the target do not (all tested).
- Full detail lives in the `sydney-css-a11y-overrides` project memory.
