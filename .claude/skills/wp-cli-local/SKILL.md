---
name: wp-cli-local
description: >-
  Drive the local podcast-local WordPress site (Local by WP Engine, Windows) via WP-CLI, MySQL, or
  PHP. Use whenever a task needs to inspect or change the local WordPress install's data — read/write
  options, manage plugins/themes, run PHP, query the database, do a serialization-safe find/replace, or
  clean up after re-importing the live database. Provides an auto-discovering `wp` wrapper that survives
  Local's PHP-version updates, plus direct MySQL access and the post-import runbook. Triggers on: WP-CLI,
  wp-cli, "wp option/plugin/search-replace/eval", wp_options, WordPress database, Local by WP Engine,
  MySQL port 10005, /lc-admin, post-import cleanup.
---

# wp-cli-local — driving the Local WordPress site

Runs WP-CLI / MySQL / PHP against the **podcast-local** site (Local by WP Engine on Windows 11).
The whole point: never hand-type the fragile `php.exe -c <ini> wp-cli.phar --path=…` incantation again,
and never let a Local PHP update break the paths.

## Quick start
Use the bundled PowerShell wrapper (paths auto-discovered at runtime):

```powershell
# from the repo root; adjust the path to the skill if needed
$wp = ".claude/skills/wp-cli-local/scripts/wp.ps1"
pwsh $wp option get siteurl
pwsh $wp plugin list --status=active
pwsh $wp eval-file ".\scratch\my-script.php"
```

Run `pwsh .claude/skills/wp-cli-local/scripts/wp.ps1` with **no arguments** to print the discovered
php / wp-cli / ini / site paths (a fast health check).

## How the wrapper finds things (why it's robust)
`scripts/wp.ps1` discovers, at runtime:
- **php.exe** — newest `php-*` under Local's `lightning-services` (so a Local PHP update won't break it).
- **wp-cli.phar** — under Local's `resources/extraResources/bin/wp-cli`.
- **run php.ini** — `%APPDATA%/Local/run/<id>/conf/php/php.ini` (this is what sets the MySQL port).
  Auto-detected; falls back to podcast-local's run id `vyyRwerqm` / port **10005** if ambiguous.
- **site path** — defaults to `<repo-root>/app/public`; override with `-SitePath`.

Override any of these: `pwsh wp.ps1 -RunId <id> -SitePath <path> <wp args>`.
The harmless `php_imagick.dll` startup warning is stripped automatically.

## Non-trivial PHP → use `eval-file`
For anything beyond a one-liner (Customizer CSS edits, creating Code Snippets, reflection, multi-line
logic), **write the PHP to a scratch file and run `eval-file`** — it avoids shell-quoting hell:

```powershell
# write PHP to a scratch file (no <?php needed is fine, but include it for clarity), then:
pwsh .claude/skills/wp-cli-local/scripts/wp.ps1 eval-file ".\scratch\task.php"
```
Note: `code_snippets()` and some plugin helpers are undefined in WP-CLI context — query
`$wpdb->prefix.'snippets'` directly, and namespaced APIs need their full namespace
(`Code_Snippets\save_snippet(new Code_Snippets\Snippet())`).

## Direct MySQL
```powershell
pwsh .claude/skills/wp-cli-local/scripts/mysql.ps1 -e "SHOW TABLES;"
```
Connection: host `127.0.0.1`, port **10005**, user/pw `root`/`root`, db `local`, table prefix `wp_`.

## Common commands
See `references/command-cheatsheet.md`. Most-used:
- `option get <key>` / `option update <key> <value>`
- `plugin list` / `plugin get <slug> --field=version`
- `search-replace OLD NEW --all-tables --skip-columns=guid` (serialization-safe — see guardrails)
- `eval-file <file.php>`

## ⚠️ Safety guardrails (follow these)
1. **`search-replace`**: always run with `--dry-run --report-changed-only` FIRST; review, then run for real.
   Use WP-CLI (serialization-safe) — **never** raw-SQL a find/replace of the domain.
2. **Back up the DB** before any destructive op: `wp db export backup-<date>.sql`.
3. **Confirm with the user** before `db import`, a real `search-replace`, `db reset`, or bulk `delete`.
4. Prefer `eval-file` over inline `eval` for anything non-trivial.
5. Login is at **`/lc-admin`** (wps-hide-login), not `/wp-admin`.

## After re-importing the live DB
Run the cleanup in `references/post-import-runbook.md` (URLs → stale transients → login → media →
SSP player). Skipping it leaves the local copy broken (fatals, wrong domain, 404s).

## Environment facts
- WP root: `app/public/`. Local URL: `http://podcast-local.local`. Target: WP 7.0, Sydney theme, SSP 3.16.2.
- Admin user `wp_admin` / `localdev` (login at `/lc-admin`).
