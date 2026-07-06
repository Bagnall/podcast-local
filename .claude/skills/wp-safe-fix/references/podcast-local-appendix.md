# podcast-local appendix (Sydney + SSP + Code Snippets specifics)

Concrete, hard-won facts for this site. Full history lives in the `sydney-css-a11y-overrides` and
`local-env-details` project memories, and the fixes are exported to `accessibility-fixes/`.

## Sydney CSS specificity trap
Sydney resets link underlines with **`!important` at specificity (0,2,0)**:
```css
:root .site :where(a:where(:not(.wp-element-button))) { text-decoration: none !important; }
```
A single-class `!important` rule (0,1,0) LOSES to it. To win, match/exceed that specificity, e.g.
`:root .site a.podcast-meta-download { text-decoration: underline !important; }`.

## The unclosed-@media brace bug (fixed)
The Customizer CSS had a `@media (max-width: 1024px) {` that was never closed, so every rule after it
was trapped inside that media query. Symptom: an appended rule "doesn't apply". Guard: brace-balance
check (`Set-CustomizerCss.ps1` reports this) and prefer inserting new blocks at the **top**.

## Code Snippets (free)
- Free edition executes **PHP snippets only**; CSS/JS-type snippets are Pro and silently inert.
- Create via `Code_Snippets\save_snippet(new Code_Snippets\Snippet())` — both are **namespaced**.
  `code_snippets()` helper is undefined in WP-CLI; query `$wpdb->prefix.'snippets'` directly.
- `Settings_Controller` (and other admin-only classes) don't exist under WP-CLI (`is_admin()` false) —
  replicate the logic instead of reflecting into them.

## SSP player
- The dark "custom colours" scheme needs `uploads/ssp/css/ssp-dynamic-style.css`, which is generated and
  **404s after a DB-only import** (and on live). The accessible choice is to **disable** custom player
  colours (`ss_podcasting_player_custom_colors_enabled = ''`) → default light theme, no 404.
- SSP + WPForms both emit per-instance `<style>` var-blocks in the body (`--ssp-episode-list-*`,
  `--wpforms-*`) which W3C flags as `<style>`-in-`<div>`; relocate them to `<head>` via output buffer.

## The 4 snippets currently deployed (names → export prefixes)
1. `Accessibility: landmarks, labels & ARIA (a11y pass)` — footer JS
2. `Accessibility: server-side markup fixes (W3C)` — output buffer
3. `Sydney: strip empty CSS declarations (W3C)` — `sydney_custom_css` filter
4. `Sydney: HTML validity fixes (W3C)` — output buffer
Export them with `-SnippetNameLike "Accessibility:%","Sydney:%"` and CSS with `-CssMarker "A11Y FIX"`.
