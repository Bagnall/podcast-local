// axe-audit.js — snippets to paste as the `code` argument of the Playwright MCP tool
// `mcp__playwright__browser_run_code_unsafe`. (These are not run from a shell.)

// ============================================================================
// A) Full WCAG audit for one page. Navigate first, or pass a URL to page.goto.
//    Returns violations (real, by rule) + incomplete (needs-review).
// ============================================================================
async (page) => {
  // IMPORTANT: audit at STEADY STATE. Sydney shows a full-screen `.preloader` overlay that JS removes
  // shortly after load; while it's up, axe's `region` rule (and other visibility-dependent checks)
  // give false NEGATIVES. Navigate with { waitUntil: 'networkidle' } — NOT 'domcontentloaded' — or the
  // skip-link `region` finding will be missed. (Learned 2026-07-15; see known-findings.md #16 + gotchas.)
  // await page.goto('http://podcast-local.local/', { waitUntil: 'networkidle' });
  await page.addScriptTag({ url: 'https://cdnjs.cloudflare.com/ajax/libs/axe-core/4.10.2/axe.min.js' });
  const out = await page.evaluate(async () => {
    // {} = all rules incl. best-practice. For WCAG-only use:
    //   { runOnly: { type:'tag', values:['wcag2a','wcag2aa','wcag21a','wcag21aa'] } }
    const r = await axe.run(document, {});
    const map = v => ({
      id: v.id, impact: v.impact, count: v.nodes.length,
      tags: v.tags.filter(t => t.startsWith('wcag') || t === 'best-practice'),
      sample: v.nodes.slice(0, 3).map(n => ({ target: n.target, html: n.html.slice(0, 140) }))
    });
    return {
      violations: r.violations.map(map),
      incomplete: r.incomplete.map(v => ({ id: v.id, count: v.nodes.length, help: v.help }))
    };
  });
  return JSON.stringify(out, null, 2);
};

// ============================================================================
// B) Gradient-aware contrast checker. axe marks player text "incomplete" because it can't measure
//    contrast across a CSS gradient. This computes the TRUE ratio against the nearest solid
//    background so you can confirm a contrast flag is a false positive (or a real failure).
//    Scope it to a selector (e.g. '.castos-player') or document.body.
// ============================================================================
async (page) => {
  const out = await page.evaluate(() => {
    const rgb = s => (s.match(/[\d.]+/g) || []).map(Number);
    const lum = c => { const a = c.slice(0,3).map(v => { v/=255; return v<=.03928 ? v/12.92 : Math.pow((v+.055)/1.055,2.4); }); return .2126*a[0]+.7152*a[1]+.0722*a[2]; };
    const ratio = (fg,bg) => { const L1=lum(fg), L2=lum(bg); return (Math.max(L1,L2)+.05)/(Math.min(L1,L2)+.05); };
    const effBg = el => { let n=el; while(n){ const c=rgb(getComputedStyle(n).backgroundColor); if(c.length && (c[3]===undefined||c[3]>0)) return c; n=n.parentElement; } return null; };
    const scope = document.querySelector('.castos-player') || document.body;
    const low = [];
    scope.querySelectorAll('*').forEach(el => {
      const hasText = [...el.childNodes].some(n => n.nodeType===3 && n.textContent.trim().length);
      const isInput = el.tagName==='INPUT' && el.value;
      if (!hasText && !isInput) return;
      const cs = getComputedStyle(el), fg = rgb(cs.color), bg = effBg(el);
      if (!fg.length || !bg) return;
      const cr = ratio(fg, bg);
      if (cr < 4.5) low.push({ text:(el.value||el.textContent).trim().slice(0,20), color:cs.color, bg:`rgb(${bg.slice(0,3)})`, ratio:+cr.toFixed(2) });
    });
    return { low_contrast_count: low.length, low_contrast: low };
  });
  return JSON.stringify(out, null, 2);
};

// Tip: pin the axe-core version (4.10.2 here) for reproducible results. Bump deliberately.
