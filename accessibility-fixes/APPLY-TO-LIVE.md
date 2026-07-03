# Applying the accessibility fixes to the LIVE site — baby steps

Follow these in order. Pause after each part. Nothing here is risky **if you do Part 0 first**.
Live site: https://podcast.langcen.cam.ac.uk · Admin login: `/lc-admin` (not `/wp-admin`).
Estimated time: ~15 minutes.

---

## Part 0 — Make a safety net (do this first)

**Why:** so any change can be undone.

1. Log in to the live admin at `https://podcast.langcen.cam.ac.uk/lc-admin`.
2. Take a database backup: **UpdraftPlus → Backup/Restore → Backup Now** → tick "Include the
   database" → **Backup Now**. Wait for "The backup apparently succeeded".
3. Extra safety for the CSS: open **Appearance → Customize → Additional CSS**, select all, copy it
   into a plain text file `live-additional-css-backup.txt` and save it.

✅ Done when: you have a fresh backup and a copy of the current Additional CSS.

---

## Part 1 — Turn off Custom Player Colours (fixes the 404 **and** the player contrast)

**Why:** the audio player is set to a custom **dark** colour scheme, but that scheme (a) makes the
Subscribe/Share URL boxes dark-text-on-dark — a real contrast failure — and (b) relies on a generated
stylesheet (`uploads/ssp/css/ssp-dynamic-style.css`) that is **missing on live (404)**. Turning custom
colours **off** makes the player use its accessible default **light** theme (dark text on light) and
stops it requesting the missing file — so the 404 disappears too. (On live this is essentially no
visual change, because the missing file already forces the light look — you're just making it
intentional and clearing the error.)

1. Go to **Podcast → Settings → Player** tab.
2. **Untick "Enable Custom Player Colors"**.
3. **Save**.
4. Check the player on any episode page — it should be light (dark text on a light background), and the
   browser console should no longer show a 404 for `ssp-dynamic-style.css`.

✅ Done when: the player is light-themed and the `ssp-dynamic-style.css` 404 is gone.

> If you specifically want to keep a **dark** player, don't do this step — instead tell me, and I'll
> give you the extra CSS needed to make the dark player pass contrast checks. The light theme is the
> simpler, already-accessible option.

---

## Part 2 — Add the accessibility CSS (the underline fix, #1)

**Why:** the "Download file" / "Play in new window" links are told apart from normal text only by
their colour. This underlines them so colour-blind users can see they're links (WCAG 1.4.1).

1. Go to **Appearance → Customize → Additional CSS**.
2. Click at the **very top** of the box, before all the existing CSS (position matters — see Part 4).
3. Paste exactly the contents of `customizer-additional-css.css`:

   ```css
   /* === A11Y FIX 1: link-in-text-block (WCAG 1.4.1) === */
   :root .site a.podcast-meta-download,
   :root .site a.podcast-meta-new-window { text-decoration: underline !important; }
   /* === END A11Y FIX 1 === */

   ```
4. Click **Publish**.

✅ Done when: published.

---

## Part 3 — Import the accessibility snippets (fixes #2–#6, #8, #9)

**Why:** adds proper labels to the player's Subscribe/Share fields and to the navigation menus, fixes a
heading that skipped a level, removes invalid ARIA attributes, strips the ~89 invalid CSS declarations
Sydney emits (the W3C "CSS Parse Error" flood), and cleans up the remaining SSP/Sydney HTML-validity
errors (share-link URL spaces, `readonly` on a button, the AMP `on="tap:"` attribute, embed-input
line-feeds, a stray `</p>`). These are PHP snippets (the free Code Snippets plugin only runs PHP).

1. Copy `code-snippets-export.json` (in this folder) somewhere easy, like your Desktop.
2. In the live admin: **Snippets → Import** → **Choose File** → select it → **Upload files and import**.
3. Four new snippets appear, all **inactive (grey)**:
   - *Accessibility: landmarks, labels & ARIA (a11y pass)*
   - *Accessibility: server-side markup fixes (W3C)*
   - *Sydney: strip empty CSS declarations (W3C)*
   - *Sydney: HTML validity fixes (W3C)*
4. **Activate all four** (they turn active/blue).

✅ Done when: all four snippets show **Active**.

---

## Part 4 — (Recommended, optional) Fix the old CSS brace bug

**Why:** the live Additional CSS has a long-standing typo — a `@media (max-width: 1024px) {` block
that was never closed with `}`, so your mobile-header and episode-list tweaks are trapped inside it and
only apply on narrow screens. Separate layout bug (not accessibility). Putting Part 2's CSS at the
**top** is what keeps it safe from this trap.

1. **Appearance → Customize → Additional CSS**. Find the single line: `grid-template-columns: 0.5fr 3fr 0.5fr;`
2. Below it is a line with one `}`. Add **one more `}`** on the next line (just before `/* Mobile layout */`):
   ```css
       grid-template-columns: 0.5fr 3fr 0.5fr;
       }
   }          ← add this line
   /* Mobile layout */
   ```
3. **Publish**, then resize the window to check desktop + mobile still look right.

---

## Part 5 — Verify

**Why:** confirm the validators are happy. (The live site is public, so the real WAVE tool works on it.)

1. Open the home page and an episode page, hard-refresh each (**Ctrl + F5**).
2. Check the Download / Play links are now **underlined**, and the player is light-themed.
3. **WAVE** (https://wave.webaim.org/) on both URLs → aim for **0 errors**.
4. **W3C** (https://validator.w3.org/nu/) on the same URLs → the `aria-label`-on-div and skipped-heading
   items should be gone. Remaining CSS/markup notices (see README) are pre-existing and not
   accessibility problems.

---

## If you need to undo
- **Player colours:** Podcast → Settings → Player → re-tick "Enable Custom Player Colors" → Save.
- **CSS:** paste your `live-additional-css-backup.txt` back → Publish.
- **Snippets:** Snippets → Deactivate (or Delete) the two imported snippets.
- **Everything:** UpdraftPlus → Restore the Part 0 backup.
