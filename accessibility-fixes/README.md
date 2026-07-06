# Accessibility fixes — podcast site

Remediation for the WordPress / Sydney / Seriously Simple Podcasting (SSP) podcast site, developed
and verified on the local mirror (`podcast-local`) on 2026-06-30. Goal: clear the accessibility
errors flagged by the WAVE and W3C validators.

## Result
- **Runtime accessibility (axe-core / WAVE / screen readers): 0 violations** across 6 page types
  (home, single episode, episode-list archive, Contact-with-form, About, series page).
- **W3C validator: 0 accessibility-related errors** (the two that overlapped our work are fixed in
  the static HTML server-side). Remaining W3C output is pre-existing, non-accessibility noise — see
  "Known / out of scope" below.

## What was fixed
| # | Issue | WCAG | Mechanism |
|---|-------|------|-----------|
| 1 | Download / "Play in new window" links distinguished by colour only | 1.4.1 | Customizer CSS (underline) |
| 2 | Subscribe/Share inputs labelled by `title` only | 3.3.2 / 4.1.2 | Snippet (runtime JS) — mirror `title`→`aria-label` |
| 3 | `aria-label` on a role-less `<div>` (`.player-panel-row`) | 4.1.2 | Snippet (server-side) — strip the attribute |
| 4 | Heading order skips `h1`→`h3` (`ssp-episode-title`) | 1.3.1 | Snippet (server-side) — rewrite `<h3>`→`<h2>` |
| 5 | Multiple unlabeled `<nav>` landmarks | 1.3.1 | Snippet (runtime JS) — unique `aria-label`s |
| 6 | Bare `<aside>` becomes a misplaced complementary landmark | 1.3.1 | Snippet (runtime JS) — `role="presentation"` |
| 7 | Player custom **dark** colours caused a real contrast failure (Subscribe/Share URL inputs = 1.56:1) **and** a missing-stylesheet 404 | 1.4.3 | **Disable "Enable Custom Player Colors"** in SSP settings → accessible default **light** theme, and the 404 disappears (file no longer requested) |
| 8 | Sydney emits ~89 invalid CSS declarations (empty values `color:;`, bare units `letter-spacing:px;`, invalid `font-weight:regular`) → the W3C "CSS Parse Error" flood | — (W3C/CSS validity) | Snippet — hooks the theme's own `sydney_custom_css` filter and strips empty/invalid declarations at source |
| 9 | Pre-existing SSP/Sydney HTML-validity errors: spaces in share-link URLs, `readonly` on a `<button>`, AMP `on="tap:"` on go-top, line-feed in embed `<input value>`, stray `</p>` from wpautop, and a `<style>` inside a `<div>` (SSP episode-list block) | — (W3C/HTML validity) | Snippet — output buffer: `%20`-encode href spaces, drop `readonly`/`on=`, collapse the embed value's newlines, remove the orphan `</p>`, and relocate the SSP episode-list **and** WPForms per-instance `<style>` blocks into `<head>` |
| ★ | **Pre-existing bug:** unclosed `@media (max-width:1024px)` in Customizer CSS swallowed later rules | — | Added the missing `}` |

> #3 and #4 are *also* W3C static-HTML errors, so they are fixed server-side (a static validator
> never runs the JS). #2/#5/#6 are runtime-only concerns, so JS is sufficient for them. #7 is a
> **settings** change, not code — turning custom colours off avoids patching a dark theme entirely.

## Bundle contents
- `customizer-additional-css.css` — the CSS fix block (#1).
- `code-snippets-export.json` — five PHP snippets, importable into the Code Snippets plugin:
  - *Accessibility: landmarks, labels & ARIA (a11y pass)* — runtime JS for #2/#5/#6.
  - *Accessibility: server-side markup fixes (W3C)* — output-buffer for #3/#4.
  - *Sydney: strip empty CSS declarations (W3C)* — `sydney_custom_css` filter for #8.
  - *Sydney: HTML validity fixes (W3C)* — output-buffer for #9.
  - *Accessibility: redundant link & title cleanup (WAVE)* — runtime JS for #10/#11.

## Applying to the LIVE site
See **[APPLY-TO-LIVE.md](APPLY-TO-LIVE.md)** for detailed step-by-step instructions. In short:
0. Back up (UpdraftPlus + copy the current Additional CSS).
1. **Disable "Enable Custom Player Colors"** (Podcast → Settings → Player) — accessible light player + kills the 404.
2. Paste `customizer-additional-css.css` at the **top** of Appearance → Customize → Additional CSS (Fix #1).
3. **Snippets → Import** `code-snippets-export.json`, then **activate all five** (Code Snippets free runs PHP snippets only).
4. *(Optional)* fix the unclosed `@media (max-width:1024px)` brace in the Additional CSS.
5. Re-run WAVE + W3C on home / an episode / the archive.

## Known / out of scope (documented false positives, not real barriers)

**W3C:** nothing remains — home and single-episode pages both validate with **0 W3C errors** and **0
axe violations**. (Relocating the episode-list `<style>` to `<head>` did not unmask any hidden errors.)

**axe contrast "needs review":** axe marks ~7 player elements color-contrast **"incomplete"** — it can't
measure across the player's CSS gradient background. With the light theme the text is dark on a light
gradient and reads fine; WAVE does not flag these. "Needs review" ≠ error.

**WAVE — WPForms anti-spam honeypot** (on `/register-for-updates/`): WAVE flags a hidden text field on
the WPForms form. It's the form's anti-spam **honeypot**, and it's a **false positive** — the field
carries `aria-hidden="true"` + `tabindex="-1"`, so it's removed from the accessibility tree and
unreachable by keyboard (axe reports 0 violations). Left as-is and documented. WPForms support confirmed:

> What WAVE is detecting might be our anti-spam honeypot field. It's a hidden text input that bots often
> fill in (since they can't tell it's invisible), which allows WPForms to silently filter out spam
> submissions without displaying a CAPTCHA.
>
> If you'd prefer to remove it, you can do so in the form builder. Simply open your form, go to Settings
> » Anti-Spam & Security, and toggle off the Anti-spam honeypot option, then save the form.
>
> Just keep in mind that disabling it may increase spam submissions slightly, so you may want to consider
> enabling another anti-spam option instead: https://wpforms.com/docs/how-to-prevent-spam-in-wpforms/
>
> If disabling the honeypot doesn't resolve the issue, please share a link to the page where the form is
> embedded so we can take a closer look.

Recommendation: leave it (documented false positive), or — if a clean WAVE result is wanted — switch to
WPForms **Modern Anti-Spam** (a hidden `type="hidden"` token that WAVE doesn't flag) rather than simply
disabling the honeypot without a replacement.

## Follow-up round (2026-07-06): three new WAVE alerts

The site owner's manager sent this prompt (verbatim) asking for these three WAVE alerts to be fixed:

> Act as a WordPress accessibility expert. Your task is to help me fix the following WAVE alerts on my
> site (podcast.langcen.cam.ac.uk): Redundant links, Redundant title text, and a visually hidden HTML5
> video. Provide step-by-step instructions to identify and fix these issues in my WordPress theme
> files.
>
> For redundant links: Ask to generate a PHP function that filters menus or content to remove
> duplicate adjacent links. For redundant titles: Ask for a JavaScript or PHP snippet to strip title
> attributes that match link text. For the hidden video: Ask for help finding in your theme's
> single.php, page.php, or a custom post type template where an embed might be wrapped in a hidden
> class, and how to properly display it.

**Comment on this prompt:** the three alerts are legitimate to investigate, but the suggested approach
conflicts with how this project fixes things, for reasons already established here:
- It asks to edit theme files directly (`single.php`, `page.php`). Sydney has **no child theme**, so
  any such edit is wiped on the next theme update. This project's rule is Customizer Additional CSS or
  a Code Snippet instead (see the rest of this document) — same visible effect, survives updates.
- It asks for **blanket** fixes — "remove duplicate adjacent links" across all menus/content, and
  "strip title attributes that match link text" everywhere — without first finding the actual
  offending elements. A generic filter like that risks mangling links/menus elsewhere on the site that
  WAVE never flagged. We investigated the concrete DOM first and scoped the fixes to what's actually
  there (below), which is safer and matches the project's existing triage practice (see
  "Known / out of scope" above).
- The "hidden video" turned out to be an `<audio>` element, not a `<video>` — likely how the manager
  paraphrased WAVE's alert, or how WAVE itself labelled it.

**Findings** (axe-core + manual DOM inspection, live site, home + episode page):

| Alert | Verdict | Detail |
|---|---|---|
| Hidden HTML5 audio | **False positive** — document, don't fix | It's Seriously Simple Podcasting's Castos player: a hidden `<audio class="clip-NNN">` used purely as the playback engine behind a fully custom, accessible control skin (`<button aria-label="Play Episode" aria-pressed="false">`, a progress bar). axe reports 0 violations for it. Un-hiding it would just add a redundant, unstyled second player with no accessibility benefit — same category as the WPForms honeypot false positive above. *(Incidental, unrelated finding: the progress bar is `role="progressbar"` and not focusable, so seeking is mouse-only — a separate WCAG 2.1.1 gap, not part of this alert, not yet actioned.)* |
| Redundant title text | **Fixed** (#10) | The header logo link duplicated its own accessible name: `<a title="Language Centre – Podcasts"><img alt="Language Centre – Podcasts"></a>`. Appeared twice (Sydney's Header/Footer Builder renders separate desktop/mobile nav instances). Fix: strip `title` only when it exactly matches the link's own accessible name (alt/text) — narrow enough to be safe site-wide. |
| Redundant link | **Fixed** (#11) | Every episode-list item on the home page linked to the same episode URL 2–3 times, adjacently (thumbnail image link + title text link + sometimes a "Listen now" button, identical `href`). Fix: `aria-hidden="true" tabindex="-1"` on the redundant image-only link when a sibling text link already points to the same URL — scoped to podcast-listing items (`li`/`article` ancestor), not a site-wide link filter. |

Both fixes were built as a 5th Code Snippet, *Accessibility: redundant link & title cleanup (WAVE)*,
verified on the local mirror, then **applied to LIVE (2026-07-06)** — added directly via Snippets →
Add New (not a re-import, to avoid duplicating the four already-live snippets). Verified on the public
site via the Playwright MCP: both patterns resolved (0 redundant titles, all episode-thumbnail links
correctly `aria-hidden`/`tabindex="-1"`), no new axe violations (the pre-existing unrelated `region`/
skip-link finding remains, unchanged). See `known-findings.md` items #10/#11 for the full detail.

**Fixed (2026-07-06, later same day):** while confirming the hidden-audio false positive, we noticed
the player's seek/progress bar (`.ssp-progress`, `role="progressbar"`) wasn't focusable or
keyboard-operable — only play/pause was. It wasn't one of the three alerts requested, but rather than
leave it as an open item, it's now fixed. Turned out to be a one-line gap: SSP's own player script
(`castos-player.min.js`) already contains ArrowLeft/ArrowRight keydown handling for this element — it
was dead code because the div had no `tabindex`, so it could never receive keyboard focus in the first
place. Setting `role="slider"` + `tabindex="0"` + `aria-label="Seek"` was the entire fix; SSP's
existing handler does the rest. Verified with a property-setter spy on the underlying `<audio>`
element: a single ArrowRight press now advances playback by exactly one step (no double-seeking),
confirmed on both single-episode pages and all 9 players on the Episode List page. See
`known-findings.md` #14.

### Broadening the fixes + full-site sweep (2026-07-06, same day)

The redundant-title fix above only checked `<a title>` elements against the link's own text/`img alt`.
Re-checking with WAVE directly turned up more instances the narrow version missed:
- **Subscribe/Share `<button title="Subscribe">Subscribe</button>`** — buttons, not links, so the
  original `a[title]` selector never reached them.
- **Facebook/Twitter share-icon links** — `title` duplicated `aria-label` (not visible text/alt), which
  the original comparison didn't check.
- **RSS/Episode-URL/Embed-code `<input>` fields** — a side effect of the *original* remediation's fix
  #2 (mirror `title`→`aria-label`): once `aria-label` exists and equals `title`, the leftover `title`
  becomes redundant. Only surfaced in WAVE after test podcast images were added, which made more
  episode rows render their full markup.
- **Podcast-artwork `<img title="French" alt="French">`** — a bare image with `title` duplicating its
  own `alt`.

The snippet was broadened to check `a`, `button`, `input`, and `img`, and to compare `title` against
`aria-label` as well as own text/alt. Verified 0 remaining across local, then applied to live the same
way (edit the existing snippet).

With that resolved, we checked **every page on the site** (26 URLs from the sitemap: all static pages,
all 10 episodes, both series and archive listings) rather than just the two pages checked so far.
Result:
- Redundant title text: **0 remaining, all 26 pages.**
- Redundant link: found on 4 pages (home + French/Spanish/English series pages) — all correctly
  `aria-hidden`, same false positive as documented above (WAVE keeps flagging it; the real barrier is
  gone).
- Hidden audio: present on every episode-bearing page — always the same documented false positive.
- **New finding, fixed:** the Episode List page (`/podcast/`) renders a full player per episode (unlike
  other listing pages), so SSP's hardcoded `aria-label="Podcast player"` / `"Podcast subscribe and
  share"` collided across instances (axe `landmark-unique`), and 6 sidebar widgets nested inside
  another landmark region (axe `landmark-complementary-is-top-level`). Fixed by extending the original
  landmarks/ARIA snippet: labels get the episode title appended when duplicated, and the aside→
  `role="presentation"` fix was broadened to the sidebar. See `known-findings.md` #12.
- **New finding, resolved by deletion:** `/sample-page/` — WordPress's unedited default placeholder
  page, not linked from navigation, had the same "link distinguished by colour only" issue as the very
  first fix in this project. Deleted rather than remediated, since it shouldn't have been public.
- **New finding, documented as accepted:** the home page (and every page, via the shared header) shows
  an axe `region` violation — the skip-link sits before the header, outside any landmark, so it's the
  first focusable element on the page. This is a conventional skip-link placement; left as-is. See
  `known-findings.md` false positive #5.

**Current state, verified 2026-07-06: every accessibility flag on the site is either fixed or explicitly
documented — none are silently outstanding.**

## W3C validator warnings (2026-07-06, separate follow-up)

The site owner's manager also wanted every W3C Nu validator message addressed, not just accessibility
alerts — including plain "info"/"warning" notices, which are much lower severity than errors but still
show up in the report. Running the validator against the home page's static HTML (not just axe's
runtime DOM check) surfaced 50 messages, none of them `error` type (consistent with the "0 W3C errors"
result above), split into:

| Message | Count | Source |
|---|---|---|
| `The "type" attribute is unnecessary for JavaScript resources.` | 1 | CookieYes's injected `<script id="cookieyes" type="text/javascript" …>` tag |
| `The "main" role is unnecessary for element "main".` | 1 | `<main id="main" class="post-wrap" role="main">` — the role is already implicit on `<main>` in HTML5 |
| `Trailing slash on void elements has no effect…` | 48 | Self-closing void elements (`<meta … />`, `<link … />`, etc.) emitted throughout by WordPress core/theme/plugins — harmless in HTML5, but flagged as noise |

All three are safe, well-understood HTML5 cleanups (removing them changes nothing about how the page
renders or behaves). Fixed by extending the existing *Sydney: HTML validity fixes (W3C)* Code
Snippet (output buffer, `template_redirect`) with three more `preg_replace` passes — see
`known-findings.md` #13. Since the hook runs on every front-end page (not just home), the fix applies
site-wide automatically.

**Verified 2026-07-06:** re-ran the W3C validator against all 25 pages on the site (home + 24 others)
after the fix — **0 messages of any kind on every single page**, not just 0 errors.

## Important caveat
These fixes live in the database (the `custom_css` option + the `wp_snippets` table). Re-importing a
live UpdraftPlus database into the local mirror will overwrite them locally. The live site is the
source of truth once applied there.
