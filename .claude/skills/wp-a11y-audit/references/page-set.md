# Representative page-set to audit

Sweep these by default (they exercise every distinct template/markup path on the site). Also audit any
ad-hoc URL the user gives. Run each through **both** axe (via the MCP) and `w3c-validate.ps1`.

| Page type | Local | Live |
|-----------|-------|------|
| Home (has featured player + episode-list block) | `http://podcast-local.local/` | `https://podcast.langcen.cam.ac.uk/` |
| Single episode (Castos player, meta, subscribe/share) | `/podcast/annee-de-cesure-de-jon/` | same path |
| Episode-list archive | `/episode-list/` | same path |
| Contact (WPForms) | `/contact/` | same path |
| Register for Updates (WPForms + honeypot) | `/register-for-updates/` | same path |
| About (plain content) | `/about/` | same path |
| Series/taxonomy page | `/french/` | same path |

Notes:
- The **featured player** + **episode-list block** appear on the home page; the **Castos player** with
  subscribe/share/embed appears on single-episode pages; **WPForms** appears on Contact and Register.
- Audit **local** while developing a fix, then confirm on **live** after deploying.
- axe reads the live DOM (so it sees runtime JS fixes); `w3c-validate.ps1` reads server HTML (so it does
  NOT see footer-JS fixes — that's expected).
