# Step 2 — Create site `podcast-local`

**Status:** ✅ Done

## Goal
Create a Local site named `podcast-local` running **WordPress 7.0**, which auto-creates and
connects the local MySQL database.

## Actions
- [ ] In Local, create a new site named `podcast-local`
- [ ] Set path to `C:\Users\Richard\Local Sites\podcast-local\`
- [ ] Choose WordPress **7.0**
- [ ] Let Local create + connect the local MySQL DB
- [ ] Verify the WP admin loads

## Done when
WP admin loads at the local site URL.

## ⚠️ Caveat — folder not empty
Local normally creates the `podcast-local` folder itself. Because we pre-created it to hold
`handover.md` (and now this `tasks/` folder), Local may complain the target directory is **not empty**.

If that happens, do ONE of:
1. **Recommended:** Temporarily move `handover.md` + `tasks/` out (e.g. to `C:\Users\Richard\Local Sites\`),
   let Local create the site, then move them back; **or**
2. Let Local create the site under a slightly different name/path, then relocate the files; **or**
3. If Local offers to use the existing folder, allow it.

The WordPress install lives in `...\podcast-local\app\public\` regardless, so these docs at the
`podcast-local\` root do not interfere with WordPress.

## Useful paths (after this step)
- WP root: `C:\Users\Richard\Local Sites\podcast-local\app\public\`
- Theme: `...\app\public\wp-content\themes\sydney\`
- Plugin: `...\app\public\wp-content\plugins\seriously-simple-podcasting\`
- WP config: `...\app\public\wp-config.php`

⬅️ Prev: [Step 1 — Install Local](step-1-install-local.md) · ➡️ Next: [Step 3 — Theme + plugin](step-3-theme-and-plugin.md)
