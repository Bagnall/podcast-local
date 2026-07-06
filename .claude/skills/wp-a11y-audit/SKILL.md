---
name: wp-a11y-audit
description: >-
  Audit and remediate accessibility on the podcast-local WordPress site (Sydney theme + Seriously
  Simple Podcasting). Use for WCAG / WAVE / W3C validation work, accessibility audits, or fixing
  contrast, form-label, landmark, heading-order, ARIA, or alt-text issues. Runs axe-core via the
  Playwright MCP and the W3C Nu validator, triages real barriers vs. known false positives, then
  applies fixes at the correct layer (Customizer CSS / Code Snippets). Triggers on: accessibility,
  a11y, WCAG, WAVE, W3C validator, axe, colour contrast, aria-label, screen reader, landmark,
  form labels, heading order, alt text.
---

# wp-a11y-audit — audit & fix accessibility (podcast-local / Sydney + SSP)

The end-to-end workflow we use on this site: **audit → triage → remediate → re-verify**. Runtime checks
(axe) read the live DOM; static checks (W3C) read server HTML — you need both, and they disagree on
purpose (see the triage playbook).

## Prerequisites
- The **Playwright MCP** must be connected (see `.mcp.json`). Local site running at
  `http://podcast-local.local`; live is public at `https://podcast.langcen.cam.ac.uk`.
- For applying fixes, use the **`wp-safe-fix`** and **`wp-cli-local`** skills.

## 1) Audit
For each URL in `references/page-set.md` (and any ad-hoc URLs given):

**axe (WCAG, via the MCP):** run `references/axe-audit.js` as the `code` argument of
`mcp__playwright__browser_run_code_unsafe`. It injects axe-core and returns `violations` +
`incomplete` (needs-review). For contrast "incomplete" over gradients, run the gradient-aware
contrast computer in the same file to get the *true* ratio.

**W3C (markup validity):**
```powershell
pwsh .claude/skills/wp-a11y-audit/scripts/w3c-validate.ps1 https://podcast.langcen.cam.ac.uk/
pwsh .claude/skills/wp-a11y-audit/scripts/w3c-validate.ps1 http://podcast-local.local/ -Full
```
It prints total / CSS-parse / HTML(non-CSS) error counts and lists the HTML errors.

**WAVE** can't be automated (needs its browser extension / a public URL). If the user pastes a WAVE
report, interpret it with the triage playbook.

## 2) Triage — real barrier vs. false positive
Use `references/triage-playbook.md`. Key rule: **validators are hints, not verdicts.** Known
false positives on this site: white-on-dark-gradient contrast (axe can't read gradients), the WPForms
`aria-hidden` honeypot, and WAVE flagging server markup that runtime JS has already fixed.

## 3) Remediate — at the right layer
- **CSS** → Customizer Additional CSS. **Runtime attribute/markup (AT-only)** → a footer-JS Code
  Snippet. **Static-HTML errors W3C flags** (aria-on-div, heading level, empty CSS, invalid markup) →
  a server-side output-buffer Code Snippet or the `sydney_custom_css` filter. See `wp-safe-fix`.
- Never edit theme/plugin files. Fixes are DB-resident → also export them to `accessibility-fixes/`.

## 4) Re-verify
Re-run axe + W3C on the changed pages. Target: **0 axe violations** and **0 accessibility-related W3C
errors**; document any residual needs-review items (e.g., gradient contrast) as accepted.

## What "done" looks like here (baseline achieved 2026-07)
Home + episode + archive + WPForms pages: 0 axe violations, 0 W3C errors. See
`references/known-findings.md` for the exact issues and the fixes that resolved them.
