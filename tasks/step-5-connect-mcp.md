# Step 5 — Connect an MCP

**Status:** ✅ Done

## Goal
Connect an **MCP** so Claude can inspect/debug the local site.

## Actions
- [x] Decide MCP: **Browser / Playwright MCP** (chosen 2026-06-29) for theme/CSS/JS + SSP player debugging
- [x] Pre-flight: Node v22 + npx present; installed Playwright **Chromium** to `%LOCALAPPDATA%/ms-playwright`
- [x] Configure: created project `.mcp.json` with `playwright` server (`npx -y @playwright/mcp@latest`)
- [x] Load & approve: restarted Claude Code; `playwright` tools loaded
- [x] Verify: navigated to the debug page, confirmed title + read console (2 errors found — see Notes)

## Done when
Claude can inspect/debug the local site through the MCP (browser tools connected + a successful test).

## Notes
- MCP = Browser/Playwright. Config is project-scoped (`.mcp.json`); Claude Code asks to approve it on load.
- MCP servers load at startup → new tools appear only AFTER a Claude Code restart.
- Test target after reload: `http://podcast-local.local/podcast/annee-de-cesure-de-jon/` (the page we debugged).

## Verification result (2026-06-29)
Navigated to `…/podcast/annee-de-cesure-de-jon/` — title rendered correctly. Console showed 2 errors:
1. **404 `ssp-dynamic-style.css`** (`/wp-content/uploads/ssp/css/`) — SSP's dynamically generated
   player stylesheet; not in the `wp-content` extract (lives in `uploads/`). **FIXED 2026-06-29**:
   regenerated via WP-CLI using SSP's own `generate_player_css` logic → now serves `200`. Recurs on
   any DB re-import; see the `post-import-runbook` memory.
2. **CookieYes "URL has changed"** — third-party CDN banner detecting domain mismatch; harmless on
   localhost, no fix needed.

⬅️ Prev: [Step 4 — Import live DB](step-4-import-live-db.md)
