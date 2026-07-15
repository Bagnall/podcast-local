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
3. Three new snippets appear, all **inactive (grey)**:
   - *Accessibility: landmarks, labels & ARIA (a11y pass)*
   - *Sydney: strip empty CSS declarations (W3C)*
   - *Sydney: HTML validity fixes (W3C)*

   *(The bundle no longer includes "Accessibility: server-side markup fixes (W3C)" — SSP 3.16.3 fixes
   #3/#4 natively. The fifth snippet, "redundant link & title cleanup", is added separately in Part 6.)*
4. **Activate all three** (they turn active/blue).

✅ Done when: the three snippets show **Active**.

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

## Part 6 — Follow-up round (2026-07-06): redundant link & title cleanup

**Why:** fixes two WAVE alerts found in a follow-up review — the header logo's `title` duplicating its
own `alt` text, and episode-list thumbnails linking the same URL twice adjacently (image + title).
See `README.md` "Follow-up round" for full detail. This is a **single new snippet**, not a re-import —
the other four snippets from Part 3 are already live, and re-importing the whole export file would
create duplicates of those.

1. **Safety net:** take a fresh UpdraftPlus database backup (Part 0, step 2) — the content has changed
   since the last backup.
2. In the live admin: **Snippets → Add New**.
3. **Title:** `Accessibility: redundant link & title cleanup (WAVE)`
4. Paste this into the code editor (no `<?php` tag needed — the editor adds it):

   ```php
   add_action( 'wp_footer', function () {
       ?>
   <script id="a11y-redundant-link-title-fix">
   (function () {
     function findItemAncestor(el) {
       var node = el;
       for (var i = 0; i < 6 && node; i++) {
         if (node.tagName === 'LI' || node.tagName === 'ARTICLE') return node;
         node = node.parentElement;
       }
       return null;
     }

     function run() {
       // Redundant title text: title duplicates the link's own accessible name (own text, or child img alt)
       document.querySelectorAll('a[title]').forEach(function (a) {
         var title = (a.getAttribute('title') || '').trim();
         if (!title) return;
         var img = a.querySelector('img[alt]');
         var ownText = img ? (img.getAttribute('alt') || '').trim() : (a.textContent || '').trim();
         if (ownText && title.toLowerCase() === ownText.toLowerCase()) {
           a.removeAttribute('title');
         }
       });

       // Redundant link: an image-only link duplicating a nearby text link to the same URL
       document.querySelectorAll('a[href] > img:only-child').forEach(function (img) {
         var a = img.parentElement;
         if ((a.textContent || '').trim() !== '') return;
         var item = findItemAncestor(a);
         if (!item) return;
         var alt = (img.getAttribute('alt') || '').trim().toLowerCase();
         if (!alt) return;
         var href = a.getAttribute('href');
         if (!href) return;
         var candidates = item.querySelectorAll('a[href="' + href.replace(/"/g, '\\"') + '"]');
         candidates.forEach(function (b) {
           if (b === a) return;
           var btext = (b.textContent || '').trim().toLowerCase();
           if (btext && (btext === alt || alt.indexOf(btext) !== -1 || btext.indexOf(alt) !== -1)) {
             a.setAttribute('aria-hidden', 'true');
             a.setAttribute('tabindex', '-1');
           }
         });
       });
     }

     if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', run); else run();
   })();
   </script>
       <?php
   }, 99 );
   ```

5. Under **"Where to run"**, choose **"Only run on site front-end"** (matches the other four snippets —
   Code Snippets free only executes PHP-type snippets).
6. Click **Save Changes and Activate**.

✅ Done when: the snippet shows **Active**.

### Verify
1. Open the live home page, hard-refresh (**Ctrl + F5**).
2. **View page source** (Ctrl+U) won't show the fix (it's added by JS after load) — instead use the
   browser DevTools **Elements** panel:
   - Inspect the header logo link — its `title` attribute should be gone.
   - Inspect an episode-list thumbnail image's parent `<a>` — it should now have
     `aria-hidden="true" tabindex="-1"`, while the text-title link next to it does not.
3. Re-run **WAVE** (https://wave.webaim.org/) on the home page → the "Redundant link" and "Redundant
   title text" alerts should be gone. The "hidden HTML5 video/audio" alert will still appear — that one
   is a documented false positive (see README), not something to fix.

### If you need to undo this part
Snippets → find *Accessibility: redundant link & title cleanup (WAVE)* → Deactivate or Delete.

---

## Part 7 — SSP 3.16.3 delta (2026-07-15): retire one snippet + patch two for the new `<textarea>`

**Only relevant once the live site is running Seriously Simple Podcasting 3.16.3+** (check **Plugins** →
Seriously Simple Podcasting version). 3.16.3 fixes the player's `aria-label`-on-div (#3) and heading-skip
(#4) natively, but its change of the Embed field from `<input>` to `<textarea>` created a new
`label-title-only` accessibility violation that the already-live snippets don't catch.

**Why:** remove a now-redundant snippet and close the one new gap the upgrade opened.

1. **Safety net:** UpdraftPlus database backup (Part 0, step 2).
2. **Delete the redundant snippet.** Snippets → find *Accessibility: server-side markup fixes (W3C)* →
   **Delete**. (On 3.16.3 it does nothing — SSP now emits `role="group"` and `h2` itself.)
3. **Patch the two snippets that label the player fields** so they also cover the new `<textarea>`:
   - Open *Accessibility: landmarks, labels & ARIA (a11y pass)*. Find:
     `document.querySelectorAll('.castos-player input[title]')`
     and change the selector to:
     `document.querySelectorAll('.castos-player input[title], .castos-player textarea[title]')`
     Save.
   - Open *Accessibility: redundant link & title cleanup (WAVE)*. Find:
     `'a[title], button[title], input[title], img[title]'`
     and change it to:
     `'a[title], button[title], input[title], textarea[title], img[title]'`
     Save.

   *(Alternatively, if you haven't customised the live snippets, you can re-import the updated
   `code-snippets-export.json` in this bundle — but that risks duplicating snippets; editing in
   place is safer.)*

4. **Fix the axe "region" alert (skip-link not in a landmark)** — same *Accessibility: landmarks,
   labels & ARIA (a11y pass)* snippet. This is the "Ensure all page content is contained by landmarks"
   alert on the home/main page. Add this block just before the final `})();` line of that snippet, then
   Save:

   ```js
     document.querySelectorAll('a.skip-link').forEach(function (sk) {
       if (sk.closest('nav, [role="navigation"]')) return;
       var nav = document.createElement('nav');
       nav.setAttribute('aria-label', 'Skip links');
       sk.parentNode.insertBefore(nav, sk);
       nav.appendChild(sk);
     });
   ```

   *(Easiest alternative: copy the whole body of the "landmarks, labels & ARIA" snippet from this
   bundle's `code-snippets-export.json` and paste it over the live snippet's code — that brings the
   `<textarea>` change from step 3 and this skip-link fix in one go.)*

### Verify
1. Open an episode page, hard-refresh (**Ctrl + F5**).
2. In DevTools **Elements**, open the player's Share panel and inspect the Embed field — it should be a
   `<textarea>` with `aria-label="Embed Code"` and **no** `title`.
3. On the home page, inspect the skip-link — it should now be wrapped in `<nav aria-label="Skip links">`.
4. Re-run **axe** on home + an episode → **0 violations**, including no more "Ensure all page content is
   contained by landmarks" (`region`). **Wait for the page to fully load first** (Sydney's preloader
   overlay must be gone) — running axe mid-load hides the `region` result.

---

## If you need to undo
- **Player colours:** Podcast → Settings → Player → re-tick "Enable Custom Player Colors" → Save.
- **CSS:** paste your `live-additional-css-backup.txt` back → Publish.
- **Snippets:** Snippets → Deactivate (or Delete) the two imported snippets.
- **Everything:** UpdraftPlus → Restore the Part 0 backup.
