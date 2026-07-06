<#
.SYNOPSIS
  Idempotently add / replace / remove a marker-wrapped block in the Customizer "Additional CSS".

.DESCRIPTION
  Wraps your CSS in  /* === <Marker> === */ ... /* === END <Marker> === */  and upserts it into the
  custom_css post via wp_update_custom_css_post(). Re-running with the same marker replaces the block
  (idempotent). Content is passed to PHP via base64 to avoid shell-quoting problems, and executed
  through the wp-cli-local wrapper (wp.ps1 eval-file). Reports brace balance so malformed CSS is caught.

.PARAMETER Marker   Unique label for the block, e.g. "A11Y FIX 1".
.PARAMETER Css      The CSS rules (without the marker comments). Ignored with -Remove.
.PARAMETER Position Top (default; dodges any unclosed-@media trap) or Bottom.
.PARAMETER Remove   Remove the marked block instead of upserting.

.EXAMPLE
  Set-CustomizerCss.ps1 -Marker "MYFIX 1" -Css ".foo{color:red !important;}"
  Set-CustomizerCss.ps1 -Marker "MYFIX 1" -Remove
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Marker,
  [string]$Css = '',
  [ValidateSet('Top', 'Bottom')][string]$Position = 'Top',
  [switch]$Remove
)
$ErrorActionPreference = 'Stop'

$wp = Join-Path $PSScriptRoot '..\..\wp-cli-local\scripts\wp.ps1'
if (-not (Test-Path $wp)) { throw "wp-cli-local wrapper not found at $wp (this skill depends on it)." }

$mB = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Marker))
$cB = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Css))
$rm = if ($Remove) { 'true' } else { 'false' }

$php = @'
<?php
$marker = base64_decode('__MARKER_B64__');
$css    = base64_decode('__CSS_B64__');
$start  = "/* === {$marker} === */";
$end    = "/* === END {$marker} === */";
$block  = $start . "\n" . $css . "\n" . $end;
$existing = wp_get_custom_css();
$pattern  = '/' . preg_quote($start, '/') . '.*?' . preg_quote($end, '/') . '/s';
if (__REMOVE__) {
    $new = preg_replace($pattern, '', $existing);
    $action = 'removed';
} elseif (preg_match($pattern, $existing)) {
    $new = preg_replace($pattern, $block, $existing);
    $action = 'replaced';
} elseif ('__POSITION__' === 'Top') {
    $new = $block . "\n\n" . ltrim($existing);
    $action = 'inserted-top';
} else {
    $new = rtrim($existing) . "\n\n" . $block . "\n";
    $action = 'appended';
}
$new = trim($new) . "\n";
$res = wp_update_custom_css_post($new);
$o = substr_count($new, '{'); $c = substr_count($new, '}');
echo (is_wp_error($res) ? ('ERROR: ' . $res->get_error_message()) : ("OK ({$action})")) . "\n";
echo 'brace_balance: open=' . $o . ' close=' . $c . ($o === $c ? ' (balanced)' : ' (UNBALANCED!)') . "\n";
'@
$php = $php.Replace('__MARKER_B64__', $mB).Replace('__CSS_B64__', $cB).Replace('__POSITION__', $Position).Replace('__REMOVE__', $rm)

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("set-css-" + [guid]::NewGuid().ToString('N') + ".php")
Set-Content -LiteralPath $tmp -Value $php -Encoding UTF8
try {
  pwsh -NoProfile -ExecutionPolicy Bypass -File $wp eval-file $tmp
} finally {
  Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
}
