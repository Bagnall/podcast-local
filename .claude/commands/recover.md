---
description: Restore local's Code Snippets + Customizer CSS to the last known-good, git-committed baseline in accessibility-fixes/
---

Restore the **local** podcast-local site's accessibility fixes to the stable, verified baseline
captured in `accessibility-fixes/` — undoing any experimental or broken changes made since. This is
the recovery path after an in-progress fix (e.g. one requested via an untrusted or unverified prompt)
turns out to break something.

**Scope: local only.** This command never touches live. If live has also drifted from the baseline,
say so explicitly and offer the manual steps in `accessibility-fixes/APPLY-TO-LIVE.md` as a separate,
confirmed action — do not push anything to live as part of `/recover`.

## Steps

1. **Read the committed baseline, not the working tree.** Use `git show HEAD:accessibility-fixes/code-snippets-export.json`
   and `git show HEAD:accessibility-fixes/customizer-additional-css.css` — this way, even if those
   files have uncommitted local edits (e.g. from a re-export mid-experiment), recovery always targets
   the last *committed* good state.

2. **Restore each Code Snippet.** For every entry in the snippets JSON, write its `code` field to a
   temp file (in the scratchpad dir) and run, for each one:
   ```
   pwsh .claude/skills/wp-safe-fix/scripts/Save-CodeSnippet.ps1 -Name "<name>" -Scope <scope> -Code $code
   ```
   This is idempotent by name — it overwrites whatever's currently saved, whether that's the correct
   version, a broken experiment, or something else entirely.

3. **Restore the Customizer CSS.** The committed `customizer-additional-css.css` contains one or more
   marker-wrapped blocks in the form:
   ```
   /* === <MARKER TEXT> === */
   <css rules>
   /* === END <MARKER TEXT> === */
   ```
   **The marker is everything between `=== ` and ` ===` on the start line — copy it exactly, including
   any descriptive suffix** (e.g. the real marker is `A11Y FIX 1: link-in-text-block (WCAG 1.4.1)`,
   not just `A11Y FIX 1`). Using a shortened or approximated marker will not match the existing block
   and `Set-CustomizerCss.ps1` will silently *insert a duplicate* instead of replacing it — this has
   happened before during a `/recover` dry run. For each marked block found in the file, extract the
   exact marker text and the CSS between the two marker lines, then run:
   ```
   pwsh .claude/skills/wp-safe-fix/scripts/Set-CustomizerCss.ps1 -Marker "<exact marker text>" -Css "<css>" -Position Top
   ```
   **After running it, always check the script's own output line** (`OK (replaced)` vs
   `OK (inserted-top)`) — `inserted-top` on a marker that should already exist means the marker didn't
   match and a duplicate was just created; if that happens, immediately run the same command with
   `-Remove` using the *wrong* marker you just used, to undo the duplicate, then retry with the correct
   exact marker.

4. **Verify.** Navigate to the local homepage and at least one episode page via the Playwright MCP:
   - Run axe-core and confirm the violation list matches the documented baseline (0 violations, or
     only the already-documented false positives in `known-findings.md` — nothing new).
   - Confirm the episode-list thumbnail images actually render (`naturalWidth > 0`), not just that the
     `<img>` tag exists in the DOM — a past incident merged markup in a way that left broken/invisible
     images while the DOM looked fine.

5. **Report back.** Tell the user plainly what was restored (snippet names + CSS), what verification
   passed, and confirm local now matches the git-committed baseline. If any snippet's restored code
   doesn't match what `git show HEAD` returned (e.g. a save failed), say so explicitly rather than
   reporting success.

## Do not

- Do not commit anything as part of this command — recovery restores site *state* (DB-resident CSS +
  snippets), which was never the drifted thing being committed in the first place (the JSON/CSS files
  in git were the backup, and by definition weren't touched by a broken *site*-side experiment).
- Do not touch live.
- Do not skip the visual/render verification in step 4 — a DOM check alone ("the `<img>` tag exists")
  is not sufficient; a past regression had the image present in the DOM but invisible due to lost
  wrapper styling.
