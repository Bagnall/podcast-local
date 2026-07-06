---
name: wp-safe-fix
description: >-
  Apply update-safe, portable fixes to a WordPress site without editing theme or plugin files. Use
  whenever you need to change CSS, markup, or behaviour on the podcast-local site (or any WP site using
  Customizer CSS + the Code Snippets plugin) and want it to survive theme/plugin updates. Covers the
  fix-layer decision (CSS -> Customizer Additional CSS; PHP -> Code Snippets), the three snippet
  patterns (footer-JS runtime, output-buffer server-side, theme-filter), and exporting the fixes as a
  bundle to deploy on live. Triggers on: apply a fix, override CSS, custom CSS, Code Snippets, add a
  snippet, patch the theme without editing files, deploy fix to live, update-safe fix.
---

# wp-safe-fix — update-safe WordPress patches

Rule zero: **never edit theme or plugin files.** They're overwritten on update. Put fixes where they
survive updates and can be exported to live:

## Choose the layer (decision tree)
See `references/fix-layers.md`. Short version:
- **Visual / CSS** → Customizer **Additional CSS** (`custom_css` post).
- **Runtime attribute/DOM tweak that only assistive tech needs** (aria-label, role) → **footer-JS**
  Code Snippet (reads the live DOM after render).
- **Markup a *static* validator (W3C) flags** (aria-on-div, heading level, invalid attribute, empty CSS)
  → **server-side** Code Snippet: an output buffer, or a theme filter like `sydney_custom_css`. A static
  validator never runs JS, so these MUST be server-side.
- **Behaviour / hooks** → PHP Code Snippet on the relevant action/filter.

## Helpers (in `scripts/`) — they run through the `wp-cli-local` skill
Pass content via base64 (dodges shell-quoting), execute via `wp.ps1 eval-file`.

**Customizer CSS (idempotent, marker-wrapped):**
```powershell
pwsh .claude/skills/wp-safe-fix/scripts/Set-CustomizerCss.ps1 `
  -Marker "MYFIX 1" -Css ":root .site a.foo { text-decoration: underline !important; }" -Position Top
# remove it again:
pwsh .claude/skills/wp-safe-fix/scripts/Set-CustomizerCss.ps1 -Marker "MYFIX 1" -Css "" -Remove
```
Defaults to inserting at the **Top** (avoids the unclosed-`@media` brace trap) and **reports brace
balance** so malformed CSS is caught.

**Code Snippet (idempotent by name):**
```powershell
pwsh .claude/skills/wp-safe-fix/scripts/Save-CodeSnippet.ps1 `
  -Name "My fix" -Scope front-end -Code 'add_action("wp_footer", function(){ /* ... */ });'
# delete it:
pwsh .claude/skills/wp-safe-fix/scripts/Save-CodeSnippet.ps1 -Name "My fix" -Delete
```
Code Snippets **free edition runs PHP only** — CSS/JS-type snippets are Pro and silently inert. A PHP
snippet must print its own `<script>` (runtime) or use an output buffer / filter (server-side).

**Export a bundle for live:**
```powershell
pwsh .claude/skills/wp-safe-fix/scripts/Export-Fixes.ps1 `
  -OutDir .\accessibility-fixes -CssMarker "A11Y FIX" -SnippetNameLike "Accessibility:%,Sydney:%"
```
Writes `customizer-additional-css.css` + `code-snippets-export.json` (importable via Snippets -> Import).
See `references/apply-to-live.md` for the deploy steps and manual-add caveats.

## Snippet patterns
`references/snippet-patterns.md` has copy-paste templates for the three patterns and when to use each.

## Workflow / guardrails
1. Make + verify the fix on **local** first.
2. Prefer the smallest correct layer; match Sydney's specificity when overriding CSS (see appendix).
3. **Export** the bundle and apply to **live** (import + activate snippets, paste CSS).
4. Fixes are **DB-resident** (`custom_css` + `wp_snippets`) — a live-DB re-import wipes them; keep the
   exported bundle as the source of truth.

## podcast-local specifics
`references/podcast-local-appendix.md`: Sydney's `:root .site :where(a…)` specificity trap, the
unclosed-`@media` brace bug, Code-Snippets free/PHP-only, `save_snippet` namespaces, and the concrete
fixes already applied (cross-refs `accessibility-fixes/` and the `sydney-css-a11y-overrides` memory).
