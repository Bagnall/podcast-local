# Step 4 — Import live DB + fix URLs/prefix

**Status:** ✅ Done

## Goal
Export the **live site's database** via cPanel/phpMyAdmin and import it into the local MySQL
(DB only — not files/uploads). Then make the local site load without redirecting to the live domain.

## Actions
- [ ] Export live DB via cPanel / phpMyAdmin (SQL dump)
- [ ] Import the dump into the local MySQL DB
- [ ] Match the **table prefix** between the dump and the local install
- [ ] Fix `siteurl` and `home` in `wp_options` to the local URL
- [ ] Confirm local site loads and does NOT redirect to the live domain

## Done when
Local site loads with live content and stays on the local URL.

## Notes
- Media/uploads are **DB only** for now — expect broken images locally. Revisit if needed.
- Use **WP-CLI `search-replace`** or the **"Better Search Replace"** plugin to change the domain.
- ⚠️ Do **NOT** do a raw SQL find/replace — it corrupts serialized data.
- Unsure whether we can install plugins on the LIVE site, so plan around a **phpMyAdmin export**,
  not a migration plugin.

## Update (2026-06-29) — media + full file copy
- DB imported from UpdraftPlus `-db.gz`; URLs rewritten via `wp search-replace` (prefix `wp_` matched).
- Media: downloaded the 315 referenced files from live into `wp-content/uploads/` (DB-only import has
  no uploads). Skipped `-uploads.zip` (195 MB) to avoid duplicates — local has all referenced media.
- Files: extracted live `-plugins.zip`/`-themes.zip`/`-others.zip` so the local copy faithfully mirrors
  live (see [step-3](step-3-theme-and-plugin.md) Update). Login is now via `wps-hide-login` slug
  **`/lc-admin`** (NOT `/wp-admin`). Local admin: `wp_admin` / `localdev` / rb2136@cam.ac.uk.

⬅️ Prev: [Step 3 — Theme + plugin](step-3-theme-and-plugin.md) · ➡️ Next: [Step 5 — Connect MCP](step-5-connect-mcp.md)
