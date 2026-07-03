# Step 6 — Accessibility remediation (WAVE / W3C)

**Status:** ✅ Done

## Goal
Using the Playwright MCP connected in Step 5, find and fix the accessibility errors flagged by the
WAVE and W3C validators on the WordPress / Sydney / SSP site, at the correct (update-safe, portable)
layer.

## Actions
- [x] Audit: ran axe-core (the WCAG engine behind WAVE) via the MCP across 6 page types
      (home, single episode, episode-list, Contact+form, About, series)
- [x] Triage real barriers vs. validator noise (7 "contrast" flags = false positives, white-on-dark
      gradient 12–16:1; documented, not "fixed")
- [x] Fixed **#1** link-in-text-block (1.4.1) — underline SSP download links — Customizer CSS
- [x] Fixed **#2** label-title-only (3.3.2/4.1.2) — mirror `title`→`aria-label` — runtime JS snippet
- [x] Fixed **#3** aria-prohibited-attr (4.1.2) — strip `aria-label` from role-less div — server-side snippet
- [x] Fixed **#4** heading-order (1.3.1) — `<h3 ssp-episode-title>`→`<h2>` — server-side snippet
- [x] Fixed **#5** landmark-unique (1.3.1) — unique `aria-label`s on `<nav>`s — runtime JS snippet
- [x] Fixed **#6** landmark-complementary (1.3.1) — `role=presentation` on bare aside — runtime JS snippet
- [x] Fixed **pre-existing bug**: unclosed `@media (max-width:1024px)` brace in Customizer CSS
- [x] Verified: 0 axe violations (6 page types) AND 0 a11y-related W3C errors (home + episode)
- [x] Exported portable bundle for live → [../accessibility-fixes/](../accessibility-fixes/)
- [x] **Applied to LIVE (2026-07-01)** — user-applied under guidance (I have no live write access; verified
      via public fetch + Playwright MCP against live). Steps: disabled Custom Player Colors (404 gone +
      light player), added Fix 1 CSS, imported+activated both snippets, fixed the brace. Verified on live:
      **0 axe violations** (home + episode) and **0 accessibility-related W3C errors**. Note: live emits
      `role="group"` on `.player-panel-row` (valid) where local 3.16.2 does not — likely a second a11y
      plugin active on live (e.g. One Click Accessibility); harmless, our #3 correctly skips it.

## Done when
Site passes runtime accessibility checks (axe/WAVE) and the W3C validator shows no accessibility
errors; fixes are portable to the live site. ✅

## Notes
- **Fix layers:** CSS → Customizer "Additional CSS"; PHP → Code Snippets (FREE → CSS/JS-type snippets
  are Pro-only and inert, so PHP snippets print their own `<script>` / use an output buffer).
- **JS vs static HTML:** runtime JS fixes satisfy WAVE/axe/screen-readers (live DOM) but NOT the W3C
  validator (static, pre-JS). The two W3C-flagged markup items (#3, #4) are therefore fixed
  server-side; the rest are JS.
- **Out of scope (documented):** ~95 empty-value CSS parse errors + ~5–7 SSP/theme HTML-validity bugs
  (share-link space encoding, `readonly` on button, `<style>` in div, embed value, stray `</p>`) — not
  accessibility barriers. See [../accessibility-fixes/README.md](../accessibility-fixes/README.md).
- **Player colours (2026-07-01):** WAVE flagged the Subscribe/Share URL inputs (real 1.56:1). Root cause:
  a dark custom player palette on a `light` player. Resolved by **disabling SSP "Custom Player Colors"**
  (`ss_podcasting_player_custom_colors_enabled = ''`) → accessible default light player, which also
  removed the `ssp-dynamic-style.css` 404 (file no longer enqueued). Earlier CSS patches for this were
  removed as redundant. Apply the same on live (untick the setting).
- **W3C validity cleanup (2026-07-02):** beyond the a11y fixes, cleared the W3C *CSS/HTML validity*
  noise too — two more Code Snippets: "Sydney: strip empty CSS declarations (W3C)" (`sydney_custom_css`
  filter, ~89 empty `color:;`/`letter-spacing:px;`/`font-weight:regular` → gone) and "Sydney: HTML
  validity fixes (W3C)" (output buffer: `%20` share-URL spaces, drop `readonly`/`on="tap:"`, collapse
  embed `<input>` newlines, remove stray `</p>`, and relocate the SSP episode-list block's inline
  `<style>` into `<head>`). Applied to live + verified: **home AND episode = 0 W3C errors, 0 axe
  violations**. All four snippets active on live; bundle = 4 snippets. Details in
  `sydney-css-a11y-overrides` memory.
- **DB-resident caveat:** fixes live in `custom_css` + `wp_snippets`; a live-DB re-import overwrites them.
- Full reusable detail in the `sydney-css-a11y-overrides` memory.

⬅️ Prev: [Step 5 — Connect an MCP](step-5-connect-mcp.md)
