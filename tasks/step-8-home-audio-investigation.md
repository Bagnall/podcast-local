# Step 8 — Investigate the "hidden audio" problem on the home page

**Status:** ✅ Done (investigated 2026-07-06; documented false positive, no fix needed)

## Goal
The user reported a **hidden audio problem on the home page**
(`http://podcast-local.local/` locally / `https://podcast.langcen.cam.ac.uk/` live).

## Outcome
Triggered again independently as a WAVE "hidden HTML5 video" alert (via the site owner's manager) —
same underlying element. Investigated on 2026-07-06 using axe-core + manual DOM inspection via the
Playwright MCP:

- The "hidden audio" is a single `<audio class="clip-NNN">` (`display:none`), the actual playback
  engine behind SSP's Castos player, paired with a fully custom, accessible control skin (a real
  `<button aria-label="Play Episode" aria-pressed="false">`, keyboard-operable; a progress bar).
  **axe reports 0 violations for it.**
- **Verdict: documented false positive, left as-is.** Un-hiding the native element would just show a
  redundant, unstyled second player with no accessibility benefit — same category as the WPForms
  honeypot false positive. Full detail in `accessibility-fixes/README.md` and the `wp-a11y-audit`
  skill's `known-findings.md` (false positive #3).
- **Incidental finding, not fixed:** the player's seek/progress bar (`role="progressbar"`) isn't
  focusable, so seeking is mouse-only (WCAG 2.1.1) — separate from the hidden-audio alert, not one of
  the reported flags. Tracked as pending item #1 in `known-findings.md` for a future scoping decision.

Two other real WAVE alerts surfaced in the same investigation (redundant link, redundant title text on
the header logo + episode list) — fixed via a 5th Code Snippet, see `accessibility-fixes/README.md`
"Follow-up round (2026-07-06)".

**Full-site sweep (same day, extended scope):** checked all 26 URLs on the sitemap, not just home +
episode. Broadened the title fix to cover `button`/`input`/`img` (missed Subscribe/Share buttons,
share icons, form fields, podcast artwork). Found and fixed two new issues on the Episode List page
(`/podcast/`): colliding ARIA labels across its multiple embedded players, and nested sidebar landmark
regions. Deleted `/sample-page/` (unedited WordPress default, unlinked, not meant to be public) rather
than remediating it. Documented the site-wide skip-link `region` finding as an accepted pattern.
**Result: every accessibility flag on the site is now either fixed or explicitly documented** — see
`accessibility-fixes/README.md` for the full writeup and a boss-facing email summary was drafted from
it. All changes committed to git.

⬅️ Prev: [Step 7 — Build skills](step-7-build-skills.md)
