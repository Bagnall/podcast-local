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
- `code-snippets-export.json` — four PHP snippets, importable into the Code Snippets plugin:
  - *Accessibility: landmarks, labels & ARIA (a11y pass)* — runtime JS for #2/#5/#6.
  - *Accessibility: server-side markup fixes (W3C)* — output-buffer for #3/#4.
  - *Sydney: strip empty CSS declarations (W3C)* — `sydney_custom_css` filter for #8.
  - *Sydney: HTML validity fixes (W3C)* — output-buffer for #9.

## Applying to the LIVE site
See **[APPLY-TO-LIVE.md](APPLY-TO-LIVE.md)** for detailed step-by-step instructions. In short:
0. Back up (UpdraftPlus + copy the current Additional CSS).
1. **Disable "Enable Custom Player Colors"** (Podcast → Settings → Player) — accessible light player + kills the 404.
2. Paste `customizer-additional-css.css` at the **top** of Appearance → Customize → Additional CSS (Fix #1).
3. **Snippets → Import** `code-snippets-export.json`, then **activate all three** (Code Snippets free runs PHP snippets only).
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

## Important caveat
These fixes live in the database (the `custom_css` option + the `wp_snippets` table). Re-importing a
live UpdraftPlus database into the local mirror will overwrite them locally. The live site is the
source of truth once applied there.
