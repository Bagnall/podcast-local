# Handover — installing & deploying the `wp-cli-local` skill

A project skill that lets Claude (and you) drive the Local WordPress site via an auto-discovering
WP-CLI / MySQL wrapper. This doc walks you through finishing its deployment in baby steps.

## What's already done (by Claude)
- ✅ Skill files created under `.claude/skills/wp-cli-local/` (`SKILL.md`, `scripts/wp.ps1`,
  `scripts/mysql.ps1`, `references/`).
- ✅ Wrapper **tested working**: path auto-discovery, `option get siteurl`, `plugin list`, `mysql.ps1 -e`.
- ✅ `.gitignore` updated so `.claude/skills/` is tracked (but `settings.local.json` stays ignored).

## What YOU need to do — baby steps

### Step 1 — Sanity-check the wrapper on your machine (1 min)
Open PowerShell in the project root and run the health check:
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .claude/skills/wp-cli-local/scripts/wp.ps1
```
✅ Expected: it prints the discovered `php`, `wp`, `ini`, and `site` paths. Then try a real command:
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .claude/skills/wp-cli-local/scripts/wp.ps1 option get siteurl
```
✅ Expected: `http://podcast-local.local`.
> If Local isn't running, start it first. If it reports "multiple run dirs", pass `-RunId <id>`.

### Step 2 — Load the skill into Claude Code (1 min)
New skills are picked up when a session starts, so **start a new Claude Code session** (or restart) in
this project. Claude will then discover `wp-cli-local`.

### Step 3 — Verify it's available (1 min)
In the new session, type `/` and look for **`wp-cli-local`** in the skill list — or just ask Claude
something like *"what's the siteurl option on the local site?"* and confirm it uses the wrapper.

### Step 4 — Commit it to git (2 min, GitHub Desktop)
The change set is: the new `.claude/skills/wp-cli-local/` files + the `.gitignore` edit.
1. Open **GitHub Desktop** (repo: podcast-local, at the project root — see `handover.md` if it still
   points at the old nested folder).
2. Review the changes, add a summary like *"Add wp-cli-local skill (WP-CLI/MySQL wrapper + runbook)"*.
3. **Commit to main**, then **Push origin**.

## Task checklist
- [x] Skill files created
- [x] Wrapper tested (paths, option get, plugin list, mysql -e)
- [x] `.gitignore` allows `.claude/skills/`
- [ ] Step 1 — health check passes on your machine
- [ ] Step 2 — restarted / new Claude Code session
- [ ] Step 3 — `wp-cli-local` shows in the skill list and triggers
- [ ] Step 4 — committed + pushed via GitHub Desktop

## Your to-do list (just the human actions)
1. Run the two health-check commands (Step 1).
2. Restart Claude Code (Step 2).
3. Confirm the skill appears / triggers (Step 3).
4. Commit + push in GitHub Desktop (Step 4).

## Using it day-to-day
Once loaded, Claude will reach for this skill whenever a task needs the local WP DB/options/plugins.
Manually, the wrapper is just:
```powershell
pwsh .claude/skills/wp-cli-local/scripts/wp.ps1 <wp-cli args>
pwsh .claude/skills/wp-cli-local/scripts/mysql.ps1 -e "SQL;"
```
See `SKILL.md` for the full command cheat sheet, safety guardrails, and the post-import runbook.

## If you ever want it available in ALL projects
Move the `wp-cli-local` folder from `.claude/skills/` to `~/.claude/skills/` (user-level). It'll then
load in every project, and you can drop the `.gitignore` tracking for it here.
