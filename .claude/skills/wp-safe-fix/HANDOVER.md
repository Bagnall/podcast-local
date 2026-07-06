# Handover — installing & deploying the `wp-safe-fix` skill

A project skill for applying update-safe WordPress fixes (Customizer CSS + Code Snippets) at the right
layer, with helper scripts and an export-to-live workflow. Depends on the `wp-cli-local` skill.

## What's already done (by Claude)
- ✅ Skill files under `.claude/skills/wp-safe-fix/` (`SKILL.md`, three `scripts/*.ps1`, four `references/`).
- ✅ Helpers **tested working**:
  - `Set-CustomizerCss.ps1` — insert → replace → remove, braces balanced, real blocks untouched.
  - `Save-CodeSnippet.ps1` — create → update (same id) → delete.
  - `Export-Fixes.ps1` — exported 1 CSS block + all 4 real snippets (both arg forms).
- ✅ Git tracking for `.claude/skills/` already in place (from Skill #1).

## Dependencies
- **`wp-cli-local`** skill (the helpers call its `wp.ps1`). Keep both skills together.
- Local site running; Code Snippets plugin active (it is).

## What YOU need to do — baby steps

### Step 1 — Smoke-test the helpers (2 min)
```powershell
# CSS upsert (adds then removes a test block)
pwsh -NoProfile -ExecutionPolicy Bypass -File .claude/skills/wp-safe-fix/scripts/Set-CustomizerCss.ps1 -Marker "TEST" -Css ".t{color:red !important;}"
pwsh -NoProfile -ExecutionPolicy Bypass -File .claude/skills/wp-safe-fix/scripts/Set-CustomizerCss.ps1 -Marker "TEST" -Remove
# export the current fix bundle to a temp folder
pwsh -NoProfile -ExecutionPolicy Bypass -File .claude/skills/wp-safe-fix/scripts/Export-Fixes.ps1 -OutDir $env:TEMP\sf-test -CssMarker "A11Y FIX" -SnippetNameLike "Accessibility:%,Sydney:%"
```
✅ Expected: `OK (inserted-top)` / `OK (removed)` with balanced braces; export reports 1 CSS block + 4
snippets.

### Step 2 — Load the skill (1 min)
Start a new Claude Code session (or restart) so it discovers `wp-safe-fix`.

### Step 3 — Verify it triggers (2 min)
Ask Claude to *"add a small CSS override"* or *"create a Code Snippet that …"* and confirm it uses this
skill's helpers/patterns (and the correct layer) rather than editing theme files.

### Step 4 — Commit it (2 min, GitHub Desktop)
Change set: `.claude/skills/wp-safe-fix/` files. Commit *"Add wp-safe-fix skill (Customizer CSS +
Code Snippets helpers + export)"* → Commit to main → Push.

## Task checklist
- [x] Skill files created
- [x] `Set-CustomizerCss.ps1` tested (idempotent, safe, brace-balance report)
- [x] `Save-CodeSnippet.ps1` tested (create/update/delete idempotent)
- [x] `Export-Fixes.ps1` tested (1 CSS block + 4 snippets)
- [ ] Step 1 — helpers smoke-test on your machine
- [ ] Step 2 — restarted / new Claude Code session
- [ ] Step 3 — skill triggers and uses the right layer
- [ ] Step 4 — committed + pushed via GitHub Desktop

## Your to-do list (just the human actions)
1. Run the Step 1 smoke-test commands.
2. Restart Claude Code.
3. Confirm the skill triggers on a fix request.
4. Commit + push in GitHub Desktop.

## Notes
- Helpers pass content to PHP via **base64** (no quoting pain) and run through `wp-cli-local`'s `wp.ps1`.
- When passing multiple `-SnippetNameLike` patterns, use **one quoted comma-separated string**
  (`"Accessibility:%,Sydney:%"`) — `pwsh -File` mangles the `"a","b"` array form (the script cleans it
  up, but the single-string form is clearer).
- Fixes are DB-resident; keep the exported bundle (`accessibility-fixes/`) as the source of truth.
