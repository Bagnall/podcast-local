# Step 7 — Build reusable WordPress skills

**Status:** ⏳ In progress (3 of 5 built)

## Goal
Capture this project's hard-won WordPress / Sydney / SSP / accessibility / security knowledge as
Claude Code **project skills**, so future sessions (and other WP work) are faster and more reliable.

## Decisions (agreed with the user)
- **Location:** project-level `.claude/skills/` (not user-level). `.gitignore` was updated to un-ignore
  `.claude/skills/` while keeping `.claude/settings.local.json` ignored.
- **Portability:** hybrid — scripts **auto-discover** Local's php / wp-cli / ini paths + MySQL port at
  runtime (survives Local's PHP-version updates), with podcast-local values as documented fallbacks.
- **Build flow:** one at a time → outline → approve → build → test → per-skill `HANDOVER.md`
  (each has a **task checklist + a to-do list**). Wrappers are **PowerShell**.

## The five skills
| # | Skill | Status |
|---|-------|--------|
| 1 | `wp-cli-local` — WP-CLI/MySQL wrapper + post-import runbook | ✅ Built & tested |
| 2 | `wp-a11y-audit` — axe + W3C audit / triage / remediate | ✅ Built & tested |
| 3 | `wp-safe-fix` — Customizer CSS + Code Snippets helpers + export bundle | ✅ Built & tested |
| 4 | `wp-plugin-scaffold` — scaffold a WP plugin (security/i18n/PHPCS baked in) | ☐ Not started |
| 5 | `wp-security-review` — WordPress/PHP security review | ☐ Not started |

## Built skills (each = SKILL.md + scripts/ + references/ + HANDOVER.md), all verified locally
- `.claude/skills/wp-cli-local/` — `scripts/wp.ps1`, `scripts/mysql.ps1`.
- `.claude/skills/wp-a11y-audit/` — `scripts/w3c-validate.ps1`, `references/axe-audit.js` + triage
  playbook + page-set + known-findings.
- `.claude/skills/wp-safe-fix/` — `scripts/Set-CustomizerCss.ps1`, `Save-CodeSnippet.ps1`, `Export-Fixes.ps1`.

## Immediate next actions
1. **Commit** the new skills + the `.gitignore` change in GitHub Desktop (see `../handover.md`).
2. A fresh Claude Code session loads skills 1–3 automatically (confirmed available).
3. **Resume at Skill #4 `wp-plugin-scaffold`.** Planned shaping questions to ask first:
   (a) plugin type — general classic-PHP + block-ready / classic-only / Gutenberg block;
   (b) architecture — OOP + namespace + autoloader / functional-prefixed / both;
   (c) tooling — Composer + PHPCS (WPCS) / + PHPUnit + npm build / minimal;
   (d) delivery — generator script (`New-WpPlugin.ps1`) / copy-templates / both.
   Bake in security (escape/sanitize/nonce/caps), i18n, activation + uninstall by default.
4. Then **Skill #5 `wp-security-review`** (escaping, sanitization, `$wpdb->prepare`, nonces + capability
   checks, REST/AJAX auth, file handling — report-oriented, WP-idiomatic).

## Notes
- The three built skills encode the `local-env-details`, `post-import-runbook`, and
  `sydney-css-a11y-overrides` memories; #4/#5 will lean on the same.
- **Deferred:** moving the project to `C:\web\podcast-local` — NOT done (it's a Local-managed site; a
  raw move breaks Local). User said forget it for now.

⬅️ Prev: [Step 6 — Accessibility](step-6-accessibility.md) · ➡️ Next: [Step 8 — Home audio](step-8-home-audio-investigation.md)
