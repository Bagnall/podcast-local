<#
.SYNOPSIS
  Export DB-resident fixes (marked Customizer CSS blocks + named Code Snippets) to a portable bundle.

.DESCRIPTION
  Produces two files in -OutDir:
    customizer-additional-css.css  (all Customizer blocks whose marker starts with -CssMarker)
    code-snippets-export.json      (snippets whose name matches any -SnippetNameLike pattern; importable
                                    via Snippets -> Import on the target site)
  Runs via the wp-cli-local wrapper.

.EXAMPLE
  Export-Fixes.ps1 -OutDir .\accessibility-fixes -CssMarker "A11Y FIX" -SnippetNameLike "Accessibility:%","Sydney:%"
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$OutDir,
  [string]$CssMarker = 'A11Y FIX',
  [string[]]$SnippetNameLike = @('Accessibility:%', 'Sydney:%')
)
$ErrorActionPreference = 'Stop'

# `pwsh -File` can deliver -SnippetNameLike as one literal token (incl. embedded quotes/commas), e.g.
# '"Accessibility:%","Sydney:%"'. Normalise: split on commas, strip surrounding quotes/whitespace.
$SnippetNameLike = @(
  $SnippetNameLike |
    ForEach-Object { $_ -split ',' } |
    ForEach-Object { $_.Trim().Trim('"', "'") } |
    Where-Object { $_ -ne '' }
)

$wp = Join-Path $PSScriptRoot '..\..\wp-cli-local\scripts\wp.ps1'
if (-not (Test-Path $wp)) { throw "wp-cli-local wrapper not found at $wp (this skill depends on it)." }

$abs = if ([IO.Path]::IsPathRooted($OutDir)) { $OutDir } else { Join-Path (Get-Location).Path $OutDir }
$oB = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($abs))
$mB = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($CssMarker))
$lB = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($SnippetNameLike -join "`n")))

$php = @'
<?php
$outDir    = base64_decode('__OUTDIR_B64__');
$cssMarker = base64_decode('__CSSMARKER_B64__');
$likes     = array_values(array_filter(explode("\n", base64_decode('__LIKES_B64__'))));
if (!is_dir($outDir)) { wp_mkdir_p($outDir); }

// --- Customizer CSS blocks ---
$css = wp_get_custom_css();
$pat = '/\/\* === ' . preg_quote($cssMarker, '/') . '.*?=== END [^*]*? === \*\//s';
$nBlocks = preg_match_all($pat, $css, $m) ? count($m[0]) : 0;
$blocks = $nBlocks ? implode("\n\n", $m[0]) : '';
$header = "/*\n * Exported Customizer Additional CSS (marker prefix: {$cssMarker}).\n"
        . " * Paste at the TOP of Appearance -> Customize -> Additional CSS on the target site.\n */\n\n";
file_put_contents($outDir . '/customizer-additional-css.css', $header . $blocks . "\n");

// --- Code Snippets ---
global $wpdb; $table = $wpdb->prefix . 'snippets';
$sql = "SELECT name, description, code, scope, priority FROM {$table}";
if ($likes) {
    $sql .= ' WHERE ' . implode(' OR ', array_fill(0, count($likes), 'name LIKE %s'));
    $rows = $wpdb->get_results($wpdb->prepare($sql . ' ORDER BY id', ...$likes), ARRAY_A);
} else {
    $rows = $wpdb->get_results($sql . ' ORDER BY id', ARRAY_A);
}
$snips = array();
foreach ($rows as $r) {
    $snips[] = array(
        'name' => $r['name'], 'description' => $r['description'],
        'code' => str_replace("\r\n", "\n", $r['code']),
        'scope' => $r['scope'], 'priority' => (int) $r['priority'], 'tags' => array(),
    );
}
$export = array(
    'generator' => 'wp-safe-fix Export-Fixes',
    'date_created' => gmdate('Y-m-d H:i'),
    'snippets' => $snips,
);
file_put_contents($outDir . '/code-snippets-export.json',
    wp_json_encode($export, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));

echo "CSS blocks exported : {$nBlocks}\n";
echo "Snippets exported   : " . count($snips) . "\n";
foreach ($snips as $s) { echo "  - {$s['name']} [{$s['scope']}]\n"; }
echo "Wrote to            : {$outDir}\n";
'@
$php = $php.Replace('__OUTDIR_B64__', $oB).Replace('__CSSMARKER_B64__', $mB).Replace('__LIKES_B64__', $lB)

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("export-fixes-" + [guid]::NewGuid().ToString('N') + ".php")
Set-Content -LiteralPath $tmp -Value $php -Encoding UTF8
try {
  pwsh -NoProfile -ExecutionPolicy Bypass -File $wp eval-file $tmp
} finally {
  Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
}
