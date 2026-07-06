# The three PHP Code Snippet patterns

All created with `Save-CodeSnippet.ps1 -Name "…" -Scope front-end -Code '…'`. Code Snippets free runs
PHP only, so each pattern is PHP that either prints a `<script>` or manipulates output/data server-side.

## 1) Footer-JS (runtime DOM fix — for assistive tech only)
Use for aria-labels, roles, etc. that satisfy axe/WAVE/screen readers but that a static validator
doesn't need. Runs after the DOM exists.
```php
add_action( 'wp_footer', function () {
    ?>
<script id="my-a11y-fixes">
(function () {
  function run() {
    document.querySelectorAll('#site-navigation').forEach(function (el) {
      if (!el.getAttribute('aria-label')) el.setAttribute('aria-label', 'Primary');
    });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', run); else run();
})();
</script>
    <?php
}, 99 );
```

## 2) Output buffer (static-HTML fix — for W3C errors)
Use when a *static* validator flags the markup. Rewrites the server HTML string before it's sent.
Guard it so it only touches normal front-end HTML.
```php
add_action( 'template_redirect', function () {
    if ( is_admin() || is_feed() || is_embed() || is_404() || wp_doing_ajax()
        || ( defined('REST_REQUEST') && REST_REQUEST ) ) return;
    ob_start( function ( $html ) {
        if ( ! is_string($html) || stripos($html, '</html>') === false ) return $html;
        // e.g. strip a prohibited aria-label from a role-less div:
        $html = preg_replace_callback('/<div\b[^>]*\bclass="[^"]*\bplayer-panel-row\b[^"]*"[^>]*>/i',
            function ($m) { return preg_match('/\brole\s*=/i',$m[0]) ? $m[0] : preg_replace('/\s+aria-label="[^"]*"/i','',$m[0]); }, $html);
        return $html;
    } );
}, 0 );
```

## 3) Theme / plugin filter (fix at the source)
Cleanest when the theme/plugin passes its output through a filter. No output buffer needed.
```php
add_filter( 'sydney_custom_css', function ( $css ) {
    if ( ! is_string($css) ) return $css;
    // strip Sydney's empty declarations (color:; letter-spacing:px; font-weight:regular)
    $css = preg_replace('/[A-Za-z-]+\s*:\s*;/', '', $css);
    $css = preg_replace('/[A-Za-z-]+\s*:\s*(?=\})/', '', $css);
    $css = preg_replace('/[A-Za-z-]+\s*:\s*(?:px|em|rem|%)\s*;/i', '', $css);
    $css = preg_replace('/font-weight\s*:\s*regular\s*;?/i', '', $css);
    return $css;
}, 99 );
```

## Choosing
| The fix must be seen by… | Pattern |
|--------------------------|---------|
| Screen readers / axe / WAVE only | 1 (footer JS) |
| The W3C static validator (markup) | 2 (output buffer) or 3 (source filter) |
| Both | 2 or 3 (server-side satisfies both) |

Prefer **3 > 2 > 2-with-relocation** when a suitable filter exists — it's the least fragile.
