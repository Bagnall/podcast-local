# Handover — Local WordPress debug environment ("podcast-local")

> **Purpose of this file:** Hand this project to a fresh Claude Code session. It captures the
> goal, every decision made so far, current progress, and the exact next step. Read it top to
> bottom and continue from the **"Current status / next step"** section.

_Last updated: 2026-07-06_

---

## Goal

The user is debugging a live WordPress site. We are building a **local copy on Windows 11** so
debugging is faster, eventually connected to an **MCP** so Claude can inspect/debug the local site.

The user wants this done in **baby steps, one at a time, pausing after each step, and confirming
completion before moving on.** Keep that style.

## What we are building

- **Fresh WordPress 7.0 install** on the local Windows machine (released 2026-05-20 — it is real).
- Running on a **local MySQL database** (Local provides and auto-connects this).
- Theme: **Sydney** (free theme by aThemes).
- Plugin: **Seriously Simple Podcasting ("SSP")** — pinned to version **3.16.2** (NOT latest).
- Then **import the LIVE site's database** into the local MySQL (DB only, not files/uploads).
- Finally **connect an MCP** for debugging.

## Key decisions (already made with the user)

| Decision | Choice |
|----------|--------|
| Local tooling | **Local** app (localwp.com) by WP Engine — GUI, bundles PHP + MySQL, auto-connects WP to DB |
| Debug focus | SSP plugin behavior **and** Sydney theme issues |
| Local content | Fresh WP/theme/plugin **files**, but populated with the **live site's database** |
| Media/uploads | **DB only** for now (expect broken images locally; revisit if needed) |
| Site name | `podcast-local` |
| Site path | `C:\Users\Richard\Local Sites\podcast-local\` |
| WP files will be at | `C:\Users\Richard\Local Sites\podcast-local\app\public\` |
| Live host access | **cPanel / phpMyAdmin** available (use this to export live DB) |
| Can install plugin on LIVE site? | **Unsure** — so plan around a phpMyAdmin DB export, not a migration plugin |
| MCP client | **Playwright/Browser MCP** (chosen Step 5) — drives Chromium against the local site |

## Plan / checklist

> ⚠️ **Single source of truth for step status is the [`tasks/`](tasks/README.md) folder.**
> Do NOT track checkbox/status here — it will drift. This list is a non-authoritative overview;
> update the matching `tasks/step-N-*.md` file (and the status column in `tasks/README.md`) instead.

- **Step 1 — Install Local** — [tasks/step-1-install-local.md](tasks/step-1-install-local.md)
- **Step 2 — Create site `podcast-local`** (WordPress 7.0) — [tasks/step-2-create-site.md](tasks/step-2-create-site.md)
- **Step 3 — Sydney theme + SSP v3.16.2** — [tasks/step-3-theme-and-plugin.md](tasks/step-3-theme-and-plugin.md)
- **Step 4 — Import live DB + fix URLs/prefix** — [tasks/step-4-import-live-db.md](tasks/step-4-import-live-db.md)
- **Step 5 — Connect an MCP** — [tasks/step-5-connect-mcp.md](tasks/step-5-connect-mcp.md)
- **Step 6 — Accessibility remediation (WAVE/W3C)** — [tasks/step-6-accessibility.md](tasks/step-6-accessibility.md)
- **Step 7 — Build reusable WordPress skills (5)** — [tasks/step-7-build-skills.md](tasks/step-7-build-skills.md)
- **Step 8 — Investigate home-page "hidden audio"** — [tasks/step-8-home-audio-investigation.md](tasks/step-8-home-audio-investigation.md)

## Current status / next step

- **Live status lives in [tasks/README.md](tasks/README.md)** — check there first.
- This `podcast-local` folder was created manually to hold `handover.md` and the `tasks/` folder.
- **Steps 1–6 done, and the accessibility fixes are now APPLIED TO LIVE (2026-07-01).** The MCP
  (Playwright) was used to audit + fix, then to verify the live site (public URL). Live result:
  0 axe violations on home + episode; the SSP player 404 is gone and the player is an accessible light
  theme. W3C validity was also cleaned up (2026-07-02): **home + episode = 0 W3C errors** (CSS and
  HTML). Fixes are archived in [accessibility-fixes/](accessibility-fixes/) (Customizer CSS + 4 Code
  Snippets). Re-run the axe/WAVE audit after any SSP or Sydney update (see the
  `sydney-css-a11y-overrides` memory for update-fragility notes).

### Active workstreams (as of 2026-07-06)
- **Step 7 — building 5 reusable WordPress skills (IN PROGRESS, 3 of 5 built).** `wp-cli-local`,
  `wp-a11y-audit`, `wp-safe-fix` are built, tested, and live under `.claude/skills/` (each with its own
  `HANDOVER.md`). **Next: Skill #4 `wp-plugin-scaffold`, then #5 `wp-security-review`** — the agreed
  approach, the shaping questions to ask, and skill locations are in
  [tasks/step-7-build-skills.md](tasks/step-7-build-skills.md). A fresh session has skills 1–3 loaded
  automatically.
- **Step 8 — home-page "hidden audio" investigation (DONE, 2026-07-06), expanded into a full-site
  accessibility sweep.** The "hidden audio" was SSP's Castos player hiding its native `<audio>` behind
  a fully custom, accessible control skin — documented false positive, no fix needed. The same
  investigation (triggered by the manager's WAVE-alert prompt) fixed two real WAVE alerts site-wide
  (redundant title text, redundant link) via a 5th Code Snippet, then, once broadened to cover
  buttons/inputs/images too, all **26 pages on the sitemap** were checked (not just home + one
  episode). That surfaced and fixed two further genuine issues on the Episode List page (`/podcast/`:
  colliding ARIA labels + nested sidebar landmarks) and led to deleting `/sample-page/` (an unlinked
  WordPress default page). **Net result: every accessibility flag on the site is now either fixed or
  explicitly documented** — see `accessibility-fixes/README.md` for the full writeup. A boss-facing
  summary email was drafted from it. One incidental, unfixed finding remains tracked: the player's seek
  bar isn't keyboard-operable (WCAG 2.1.1) — see
  [tasks/step-8-home-audio-investigation.md](tasks/step-8-home-audio-investigation.md).
- All of this round's changes are **committed to git**.
- **Deferred:** moving the project to `C:\web\podcast-local` — abandoned for now (Local-managed site;
  a raw move breaks Local).

### ⚠️ Uncommitted git changes (do this first in a new session)
The new `.claude/skills/` (three skills + handovers), the `.gitignore` change (un-ignoring
`.claude/skills/`), and these `handover.md` / `tasks/` updates are **not yet committed**. Commit + push
them in **GitHub Desktop** (repo root = the project folder; branch `main`; remote Bagnall/podcast-local).

## Version control (git)

- **Repo root:** the project root `C:\Users\Richard\Local Sites\podcast-local\`. Remote:
  `https://github.com/Bagnall/podcast-local.git`, branch `main`. Managed via GitHub Desktop.
- **Fixed 2026-07-03:** the repo had been created one level too deep — a nested
  `podcast-local\podcast-local\` sub-repo containing only a stub README — so no real changes ever
  appeared in GitHub Desktop. Moved `.git` up to the project root (remote + history preserved) and
  deleted the empty nested folder. In GitHub Desktop, remove the old (nested) repo entry and
  **Add local repository** → the project root.
- **What's tracked** (see `.gitignore`): ONLY the debug/documentation artifacts — `CLAUDE.md`,
  `handover.md`, `tasks/`, `accessibility-fixes/`, `.mcp.json`. Everything else is ignored: the
  WordPress install (`app/`), Local's runtime dirs (`conf/`, `logs/`), `.claude/`, and MCP scratch
  (`.playwright-mcp/`).
- **Important:** the accessibility/validation fixes live in the WordPress **database** (Customizer
  `custom_css` + the `wp_snippets` table), NOT in files — so they never show up as git changes. The
  [accessibility-fixes/](accessibility-fixes/) bundle (CSS block + importable Code Snippets export +
  README/APPLY-TO-LIVE) is their version-controlled representation.

## ⚠️ Important caveat about this folder

Local normally **creates the `podcast-local` folder itself** during site creation. Because we
pre-created it to hold `handover.md`, Local may complain that the target directory is **not empty**
when you create the site in Step 2.

If that happens, do ONE of these:
1. **Recommended:** Temporarily move `handover.md` out (e.g. to `C:\Users\Richard\Local Sites\`),
   let Local create the site, then move `handover.md` back into `podcast-local\`; **or**
2. Let Local create the site under a slightly different name/path, then relocate this file; **or**
3. If Local offers to use the existing empty-ish folder, allow it.

The WordPress install itself lives in `...\podcast-local\app\public\` regardless, so `handover.md`
sitting at the `podcast-local\` root does not interfere with WordPress.

## Useful paths (after Step 2 completes)

- WP root: `C:\Users\Richard\Local Sites\podcast-local\app\public\`
- Theme: `...\app\public\wp-content\themes\sydney\`
- Plugin: `...\app\public\wp-content\plugins\seriously-simple-podcasting\`
- WP config: `...\app\public\wp-config.php`

## Environment notes

- OS: Windows 11 Pro. Shell: PowerShell (primary), Bash also available.
- User: Richard (rb2136@cam.ac.uk).
- Original Claude Code working dir for the first session: `C:\web`.
