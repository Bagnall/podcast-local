# Export a fix bundle and apply it to the live site

Fixes are DB-resident, so "deploying" means re-creating them on live. Export a bundle from local, then
import/paste on live.

## 1) Export from local
```powershell
pwsh .claude/skills/wp-safe-fix/scripts/Export-Fixes.ps1 `
  -OutDir .\accessibility-fixes `
  -CssMarker "A11Y FIX" `
  -SnippetNameLike "Accessibility:%,Sydney:%"   # comma-separated in ONE quoted string
```
Produces `customizer-additional-css.css` and `code-snippets-export.json`.

## 2) Apply on live (baby steps)
0. **Back up first** (UpdraftPlus DB backup + copy the current Additional CSS to a text file).
1. **CSS** — Appearance → Customize → Additional CSS. Paste the exported CSS **at the top**. If the
   existing CSS has an unclosed `@media` brace, fix it (or top-placement dodges the trap). Publish.
2. **Snippets** — Snippets → **Import** → upload `code-snippets-export.json` → then **Activate** each
   imported snippet (imports arrive **inactive** — easy to forget).
   - Import may create duplicates of snippets already present. If you're adding just one new snippet to a
     site that already has the others, prefer **Snippets → Add New** and paste that one snippet's code
     manually (PHP/Functions type, front-end) to avoid duplicates.
3. **Verify** — re-run WAVE + the W3C validator (and axe via the MCP) on a few pages.

## Caveats
- **Code Snippets free = PHP only.** The exported snippets are PHP; import works on the free edition.
- **A live-DB re-import wipes these fixes** — the exported bundle is the source of truth; keep it in git
  (e.g. `accessibility-fixes/`) and re-apply after any re-import.
- If a page still shows a `<style>`-in-`<div>` or similar after import, it's a plugin/block emitting a
  var-block not yet covered — extend the relevant output-buffer snippet's match list.
