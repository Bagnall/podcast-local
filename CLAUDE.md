# CLAUDE.md — podcast-local

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Local WordPress debug environment (Windows 11), built to debug a live podcast site faster and
eventually wire it to an MCP. Built with the **Local** app (by WP Engine).

## Start here (every session)
1. Read [handover.md](handover.md) — goal, decisions, and context ("why").
2. Read [tasks/README.md](tasks/README.md) — the **live step status and next step**.

## Working style (important)
- **Baby steps: one step at a time. Pause after each and confirm before moving on.**

## Source-of-truth rule (avoid drift)
- **Step status lives ONLY in [tasks/](tasks/README.md)** (each `step-N-*.md` `Status:` line + the
  status column in `tasks/README.md`).
- `handover.md` holds context only — never track checkbox/status there.
- When a step changes, update BOTH the step file's `Status:` line and the README status column.

## Key facts
- WP root: `app/public/`. Local site URL: `http://podcast-local.local`.
- Target: WordPress **7.0**, **Sydney** theme, **Seriously Simple Podcasting** **3.16.2**.
- Live DB imported from an **UpdraftPlus `-db.gz`** (not cPanel). Never raw SQL find/replace the
  domain — use WP-CLI `search-replace` (serialized data).

## Commands (WP-CLI, DB, browser testing)
This is a WordPress site — work is WP-CLI + DB + browser, not a build/lint/test toolchain.
- **WP-CLI**: Local bundles PHP + WP-CLI, but you must pass Local's `php.ini` so the MySQL port is set.
  Pattern: `php.exe -c <Local-run php.ini> wp-cli.phar --path="app/public" <cmd>`. Exact binary paths,
  the run-dir id, and the MySQL port (**10005**) are in the `local-env-details` memory. A harmless
  `php_imagick.dll` startup warning prints to stderr — ignore it.
- Use **`wp eval-file <file.php>`** for non-trivial PHP (Customizer CSS edits, creating Code Snippets) —
  avoids shell-quoting pain. Common: `wp search-replace OLD NEW` (serialization-safe — never raw-SQL the
  domain), `wp plugin list`, `wp option get/update`.
- **MySQL**: `127.0.0.1:10005`, `root`/`root`, db `local`, prefix `wp_`.
- **Browser/WCAG testing**: the **Playwright MCP** (`.mcp.json`) drives Chromium against the site. For
  accessibility audits, inject axe-core in `browser_run_code_unsafe` (`page.addScriptTag` cdnjs axe →
  `axe.run`). axe reads the **live DOM** (so it sees runtime JS fixes); the **W3C validator checks static
  HTML** (pre-JS) — markup errors it flags must be fixed server-side, not via JS.

## Codebase architecture (big picture)
`app/public/` is a WordPress 7.0 install mirroring live — mostly third-party. Debugging centers on two
layers, plus a fixed set of "where to patch" rules:
- **Sydney theme** (`wp-content/themes/sydney/`) uses its **Header/Footer Builder** (the `shfb-*` classes).
  Header/nav markup is NOT in classic `header.php` — it's in
  `inc/modules/hf-builder/components/header/.../menu.php` (desktop `#site-navigation`, mobile `#mainnav`);
  classic fallbacks in `inc/classes/class-sydney-header.php`. These `<nav>` wrappers are hardcoded with no
  attribute filter.
- **Seriously Simple Podcasting** (`…/plugins/seriously-simple-podcasting/`, pinned **3.16.2**): the
  "Castos" player is **server-rendered** from `templates/players/castos-player.php`; meta line + subscribe/
  share panels from `php/classes/controllers/class-players-controller.php`. Its dynamic colour stylesheet
  `uploads/ssp/css/ssp-dynamic-style.css` regenerates only when player colour settings are saved — absent
  (404) after a DB-only import; regenerate per the `post-import-runbook` memory.
- Notable plugins: **wps-hide-login** (login at `/lc-admin`), **code-snippets**, **accessibility-checker**
  (Equalize Digital), **wpforms-lite**, **cookie-law-info** (CookieYes), **updraftplus**, **google-site-kit**.

### Where to apply fixes (update-safe, portable to live; no child theme exists)
- **CSS** → Customizer **Additional CSS** (`custom_css` post, set via `wp_update_custom_css_post()`).
  Sydney's `:root .site :where(a…){text-decoration:none !important}` (0,2,0 + !important) outranks single
  classes — overrides must match its specificity. See `sydney-css-a11y-overrides` memory.
- **PHP** → **Code Snippets** (active, **free** edition → CSS/JS-type snippets are Pro-only and inert; only
  **PHP** snippets run). A PHP snippet must print its own `<script>` (runtime fix) or use a `template_redirect`
  output buffer (server-side markup fix). Create via `Code_Snippets\save_snippet(new Code_Snippets\Snippet())`
  (`code_snippets()` helper is undefined in WP-CLI — query `$wpdb->prefix.'snippets'`).
- Never edit theme/plugin files directly. Accessibility remediation (Step 6) is exported to
  `accessibility-fixes/` for the live site; fixes are DB-resident so a live-DB re-import wipes them.

## Current state (2026-06-30)
- **Steps 1–6 done.** Local faithfully mirrors live: imported DB (URLs localized), **315 media files**
  pulled from live, and the **live `wp-content` files** (live Sydney + all 9 live plugins) extracted from
  UpdraftPlus `-plugins/-themes/-others.zip` (in `Downloads/temporary/wordpress_backups/`).
- **Login is `/lc-admin`, NOT `/wp-admin`** (`wps-hide-login` active). Admin: `wp_admin` / `localdev`.
- **Playwright MCP connected** (Step 5). **Accessibility remediation done** (Step 6): 0 axe violations
  across 6 page types + 0 a11y-related W3C errors; fixes exported to `accessibility-fixes/`.
- **Applied to LIVE (2026-07-01)** — user-applied under guidance; verified via public fetch + MCP:
  0 axe violations + 0 a11y-related W3C errors on home + episode. (Live emits `role="group"` on the
  player panel row where local 3.16.2 doesn't — likely a second a11y plugin on live; harmless.)
- Reusable cleanup after any re-import: `post-import-runbook` memory. Runtime paths (MySQL port 10005,
  php/wp-cli binaries): `local-env-details` memory. A11y fix details: `sydney-css-a11y-overrides` memory.

## Environment
- OS: Windows 11 Pro. Shell: PowerShell (primary), Bash also available.
- User: Richard (rb2136@cam.ac.uk).

> This file was last reconciled with the codebase on 2026-06-30 (Steps 1–6 complete).
