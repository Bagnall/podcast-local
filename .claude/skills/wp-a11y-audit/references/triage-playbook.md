# Triage playbook — real barrier vs. false positive

Validators are **hints, not verdicts**. For every flag, ask: *does this actually block or mislead an
assistive-technology user?* Map it to a WCAG success criterion, then decide fix / document / ignore.

## The three tools disagree — on purpose
- **axe** (via MCP) reads the **live DOM** → sees runtime JS fixes (footer-JS aria-labels etc.).
- **WAVE** also reads the rendered DOM (browser extension) → like axe, sees JS fixes. Can't be automated.
- **W3C Nu** reads **static server HTML** → does NOT see JS-applied fixes. So markup-level errors it
  flags (aria-on-div, heading level, invalid attributes) must be fixed **server-side**, not with JS.

## Known FALSE POSITIVES on this site (document, don't "fix")
| Flag | Tool | Why it's a false positive |
|------|------|---------------------------|
| Colour contrast "incomplete"/error on player text | axe (incomplete) / WAVE (error) | The player background is a CSS **gradient** (a `background-image`); its `background-color` is transparent. Tools can't measure across a gradient, so they compare against the page behind it and mis-report. Real ratio (white on the dark gradient, or dark on the light theme) is well past 4.5:1 — confirm with the gradient-aware contrast computer in `axe-audit.js`. |
| Hidden text field / empty-or-missing label on the WPForms form | WAVE | It's the WPForms **anti-spam honeypot** — carries `aria-hidden="true"` + `tabindex="-1"`, so it's out of the a11y tree and unreachable by keyboard. axe reports 0. Don't add a visible label (breaks the decoy). |
| A form control whose label WAVE calls empty, but the control is `aria-hidden` | WAVE | Same principle — hidden from AT ⇒ not a barrier. |

## Real issues we DID fix (see known-findings.md)
Links distinguished by colour only (1.4.1); inputs labelled by `title` only (3.3.2/4.1.2); `aria-label`
on a role-less `<div>` (4.1.2); heading order `h1→h3` (1.3.1); unlabeled duplicate `<nav>` landmarks
(1.3.1); a bare `<aside>` complementary landmark (1.3.1); a genuine dark-on-dark input contrast fail
when custom player colours were applied (1.4.3).

## Decision shortcuts
- axe **violation** → almost always real; fix it.
- axe **incomplete** → needs review; usually a gradient/opacity case → compute the true ratio.
- WAVE **error** on a hidden/`aria-hidden` element → false positive; document.
- W3C **CSS parse error** (`color:;`, `letter-spacing:px;`, `font-weight:regular`) → invalid CSS the
  theme emits; strip via the `sydney_custom_css` filter. Not an a11y barrier but worth clearing.
- W3C **HTML error** also flagged by axe/WAVE → fix server-side (JS won't satisfy a static validator).
