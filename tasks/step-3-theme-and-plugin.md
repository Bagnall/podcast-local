# Step 3 — Install Sydney theme + SSP v3.16.2

**Status:** ✅ Done

## Goal
Install the **Sydney** theme (free, by aThemes) and **Seriously Simple Podcasting (SSP)** pinned
to version **3.16.2** (NOT latest).

## Actions
- [ ] Install + activate the **Sydney** theme
- [ ] Install **Seriously Simple Podcasting** at version **3.16.2** exactly
- [ ] Activate SSP

## Done when
Sydney is active and SSP v3.16.2 is installed + active.

## Notes
- **Must pin SSP to 3.16.2** — do not install the latest version. The latest version may be fetched
  by default; use the version dropdown on the WordPress.org plugin page (Advanced View) or upload
  the 3.16.2 zip manually.

## Update (2026-06-29) — replaced with full live files
Stock Sydney + SSP alone did not reproduce the live site (custom CSS/markup mismatches). We later
extracted the live UpdraftPlus `-plugins.zip` and `-themes.zip` into `wp-content/`, giving the
**live Sydney** (with its `functions.php`/template edits) and **all 9 live plugins**
(accessibility-checker, code-snippets, cookie-law-info, google-site-kit, seriously-simple-podcasting,
updraftplus, wp-mail-smtp, wpforms-lite, wps-hide-login; akismet + pojo-accessibility inactive).
SSP remains 3.16.2 (live's version). See [step-4](step-4-import-live-db.md) Update.

⬅️ Prev: [Step 2 — Create site](step-2-create-site.md) · ➡️ Next: [Step 4 — Import live DB](step-4-import-live-db.md)
