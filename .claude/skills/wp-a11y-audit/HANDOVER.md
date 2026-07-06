# Handover — installing & deploying the `wp-a11y-audit` skill

A project skill that audits and fixes accessibility on podcast-local (Sydney + SSP) using axe-core (via
the Playwright MCP) and the W3C validator, with a triage playbook and the known-findings record.

## What's already done (by Claude)
- ✅ Skill files created under `.claude/skills/wp-a11y-audit/` (`SKILL.md`, `scripts/w3c-validate.ps1`,
  and `references/` — axe snippets, page-set, triage playbook, known findings).
- ✅ `w3c-validate.ps1` **tested working** (live home + register-for-updates both returned 0 errors).
- ✅ Git tracking already covers `.claude/skills/` (set up with the `wp-cli-local` skill) — no
  `.gitignore` change needed this time.

## Dependencies (already satisfied here)
- **Playwright MCP** connected (`.mcp.json`) — the axe audit runs through it.
- **Internet access** — axe-core loads from cdnjs; W3C validation POSTs to `validator.w3.org`.

## What YOU need to do — baby steps

### Step 1 — Sanity-check the W3C script (1 min)
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .claude/skills/wp-a11y-audit/scripts/w3c-validate.ps1 http://podcast-local.local/
```
✅ Expected: a summary line (Errors / CSS-parse / HTML). (The axe part isn't a shell script — Claude
runs it through the Playwright MCP; you'll test that in Step 3.)

### Step 2 — Load the skill (1 min)
**Start a new Claude Code session** (or restart) so it discovers `wp-a11y-audit`.

### Step 3 — Verify it triggers (2 min)
In the new session, ask something like *"audit the accessibility of the home page"*. Claude should:
pick up this skill, drive the Playwright MCP to run axe, run `w3c-validate.ps1`, and report findings
triaged into real vs. false-positive. Confirm it uses the skill's workflow.

### Step 4 — Commit it (2 min, GitHub Desktop)
Change set: the new `.claude/skills/wp-a11y-audit/` files. Commit with a message like
*"Add wp-a11y-audit skill (axe + W3C audit/triage/remediation)"* → Commit to main → Push.

## Task checklist
- [x] Skill files created
- [x] `w3c-validate.ps1` tested (0 errors on live home + register)
- [x] Git tracking covers `.claude/skills/`
- [ ] Step 1 — W3C script runs on your machine
- [ ] Step 2 — restarted / new Claude Code session
- [ ] Step 3 — skill triggers on an audit request and runs axe + W3C
- [ ] Step 4 — committed + pushed via GitHub Desktop

## Your to-do list (just the human actions)
1. Run the W3C sanity check (Step 1).
2. Restart Claude Code (Step 2).
3. Ask Claude to audit a page; confirm the skill drives the workflow (Step 3).
4. Commit + push in GitHub Desktop (Step 4).

## Using it day-to-day
Ask for an accessibility audit / WCAG / WAVE / W3C check and Claude will run the audit→triage→fix→
re-verify loop. It leans on `wp-safe-fix` (Skill #3) to apply fixes and `wp-cli-local` (Skill #1) for
any DB/option work. Manual W3C check anytime:
```powershell
pwsh .claude/skills/wp-a11y-audit/scripts/w3c-validate.ps1 <url> [-Full]
```
