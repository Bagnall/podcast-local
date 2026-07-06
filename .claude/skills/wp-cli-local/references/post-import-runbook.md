# Post-import runbook — cleanup after (re)importing the live DB

Run these after importing the live UpdraftPlus `-db.gz` into the local `local` database, so the local
copy works. All commands via the wrapper: `pwsh ../scripts/wp.ps1 <cmd>` (or `mysql.ps1` where noted).

1. **URLs (serialization-safe).** Never raw-SQL the domain.
   ```
   wp.ps1 search-replace 'https://podcast.langcen.cam.ac.uk' 'http://podcast-local.local' --all-tables --skip-columns=guid --dry-run --report-changed-only
   # review, then run again WITHOUT --dry-run
   ```
   Do a second pass on the bare domain if needed. Prefix is `wp_` both sides.

2. **Stale transients with live absolute paths** (`/var/www/...`) survive the import and can cause fatals.
   Known offender: `_transient_sydney_pattern_files%` (Sydney caches version-keyed pattern paths).
   Find them, then delete via SQL (loading WP-CLI can re-trigger the fatal on `init`):
   ```
   mysql.ps1 -e "SELECT option_name FROM wp_options WHERE option_value LIKE '%/var/www/%';"
   mysql.ps1 -e "DELETE FROM wp_options WHERE option_name LIKE '_transient_sydney_pattern_files%';"
   ```
   `recently_edited` also holds live paths but is harmless (display-only).

3. **Login.** `wps-hide-login` slug is **`/lc-admin`** (not `/wp-admin`). Reset admin pw/email if needed:
   ```
   wp.ps1 user update wp_admin --user_pass=localdev --user_email=rb2136@cam.ac.uk
   ```

4. **Media.** A DB-only import has no uploads — broken images are expected. Re-pull referenced files from
   live if you need them.

5. **SSP player / dynamic stylesheet.** With `ss_podcasting_player_custom_colors_enabled = on` (true in
   the live DB), SSP enqueues `wp-content/uploads/ssp/css/ssp-dynamic-style.css` — a *generated* file not
   in the backup, so it 404s after import.
   - **Recommended (accessible):** disable custom colours so SSP stops requesting the file and the player
     uses its accessible default light theme:
     ```
     wp.ps1 option update ss_podcasting_player_custom_colors_enabled ''
     ```
   - *Alternative (only if the dark player is wanted):* regenerate the file by replicating SSP 3.16.2's
     `generate_player_css` via `eval-file`, then add the accessibility CSS that makes the dark player pass
     contrast. See the `sydney-css-a11y-overrides` project memory.

> ⚠️ Re-importing the live DB also **overwrites** any DB-resident fixes (Customizer `custom_css`,
> `wp_snippets`). Re-apply the accessibility bundle in `accessibility-fixes/` afterwards.
