# Fix-layer decision tree

**Never edit theme or plugin files** (overwritten on update, not portable). Choose the layer by what
the fix is and which tool must "see" it.

```
Is it purely visual (CSS)?
  └─ YES → Customizer > Additional CSS (custom_css post).  Helper: Set-CustomizerCss.ps1
           Match/beat the theme's selector specificity; prefer inserting at the TOP.

Is it a DOM/attribute tweak (aria-label, role, class) that only assistive tech needs?
  └─ YES → footer-JS Code Snippet (runs after render, edits the live DOM).
           Satisfies axe / WAVE / screen readers (they read the live DOM).
           Does NOT satisfy the W3C validator (it reads static server HTML).

Is it a markup problem a STATIC validator (W3C) flags?
   (aria-label on a role-less div, wrong heading level, invalid attribute, empty CSS declaration,
    a <style> in the body, a stray tag…)
  └─ YES → server-side Code Snippet:
             • output buffer on template_redirect (rewrite the HTML string), or
             • a theme/plugin filter that produces the markup/CSS (e.g. sydney_custom_css).
           A static validator never runs JS, so these MUST be server-side.

Is it behaviour / hooks / data?
  └─ YES → PHP Code Snippet on the relevant action/filter.  Helper: Save-CodeSnippet.ps1
```

## Why "runtime vs static" matters
- **axe** (Playwright MCP) and **WAVE** (extension) read the **rendered DOM** → they see JS fixes.
- **W3C Nu** reads the **server HTML** → it does not. So a heading-level or aria-on-div error that W3C
  reports can't be fixed with footer JS; it needs an output buffer or a source filter.

## Portability rules
- All fixes are **DB-resident** (`custom_css` + `wp_snippets`). They survive theme/plugin/core updates,
  but a **DB re-import overwrites them**. Always keep the exported bundle (Export-Fixes.ps1) as the
  source of truth and re-apply after a re-import.
- Code Snippets **free = PHP only**. CSS/JS-type snippets exist in the UI but don't execute.
