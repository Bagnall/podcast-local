# WP-CLI cheat sheet (via wp.ps1)

All examples assume you're calling the wrapper, e.g. `pwsh .claude/skills/wp-cli-local/scripts/wp.ps1 <args>`.

## Health / info
```
wp.ps1                              # print discovered php/wp-cli/ini/site paths
wp.ps1 core version
wp.ps1 option get siteurl
wp.ps1 option get home
```

## Options
```
wp.ps1 option get <key>
wp.ps1 option update <key> <value>
wp.ps1 option list --search="ss_podcasting_*"
```

## Plugins / themes
```
wp.ps1 plugin list --fields=name,status,version
wp.ps1 plugin get <slug> --field=version
wp.ps1 theme list --status=active --field=name
```

## Find/replace (serialization-safe — DRY RUN FIRST)
```
wp.ps1 search-replace OLD NEW --all-tables --skip-columns=guid --dry-run --report-changed-only
wp.ps1 search-replace OLD NEW --all-tables --skip-columns=guid          # for real, after review
```

## Running PHP (prefer eval-file for anything non-trivial)
```
wp.ps1 eval 'echo get_bloginfo("name");'
wp.ps1 eval-file .\scratch\task.php
```
Gotchas in WP-CLI context: `is_admin()` is false (admin-only controllers aren't instantiated);
`code_snippets()` helper is undefined (query `$wpdb->prefix.'snippets'`); namespaced APIs need the full
namespace (e.g. `Code_Snippets\save_snippet(new Code_Snippets\Snippet())`).

## Database
```
wp.ps1 db export backup-2026-07-03.sql     # BACK UP before destructive ops
mysql.ps1 -e "SHOW TABLES;"
mysql.ps1 -e "SELECT option_name FROM wp_options WHERE option_value LIKE '%/var/www/%';"
```

## MySQL connection facts
host `127.0.0.1` · port **10005** · user/pw `root`/`root` · db `local` · prefix `wp_`

## Safety reminders
- `search-replace` → `--dry-run` first; never raw-SQL the domain.
- Back up (`db export`) before `db import` / real `search-replace` / `db reset` / bulk delete.
- Confirm destructive/import operations with the operator.
- Login is `/lc-admin`, not `/wp-admin`.
