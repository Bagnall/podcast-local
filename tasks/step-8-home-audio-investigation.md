# Step 8 — Investigate the "hidden audio" problem on the home page

**Status:** ☐ Not started (reported, no details captured yet)

## Goal
The user reported a **hidden audio problem on the home page**
(`http://podcast-local.local/` locally / `https://podcast.langcen.cam.ac.uk/` live). We had not started
investigating when this handover was prepared — no specifics gathered.

## First moves for a fresh session
1. **Ask the user what "hidden audio" means** — e.g. a clip that autoplays with no visible player, a
   hidden/duplicate `<audio>` element, an off-screen player, sound with no controls, or a
   screen-reader/announcement issue. This shapes everything.
2. **Inspect the home page via the Playwright MCP** (`wp-a11y-audit` / the MCP directly):
   - Enumerate every `<audio>` and `.castos-player` on the page: their `display`/`visibility`, bounding
     box, `autoplay` / `muted` / `preload` / `loop` attributes, and whether any is present in the DOM but
     visually hidden.
   - The home page renders the SSP **featured Castos player** + an **episode-list block** — likely
     suspects: a second/hidden player instance, an autoplaying element, or an `aria-hidden` media control.
   - Check the console/network for audio requests firing on load.
3. **Fix at the right layer** with `wp-safe-fix` (CSS to hide/adjust, or a Code Snippet if markup/behaviour
   needs changing). Never edit theme/plugin files. Export to `accessibility-fixes/` and apply to live.

## Context
- SSP = Seriously Simple Podcasting 3.16.2; player is the server-rendered "Castos" player.
- See `wp-a11y-audit` skill (`references/known-findings.md`) and the `sydney-css-a11y-overrides` memory.

⬅️ Prev: [Step 7 — Build skills](step-7-build-skills.md)
