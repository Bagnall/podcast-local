<#
.SYNOPSIS
  Create / update / delete a named Code Snippets snippet, idempotently by name.

.DESCRIPTION
  Uses the Code Snippets API (Code_Snippets\save_snippet) via the wp-cli-local wrapper. Content is
  passed via base64 to avoid quoting problems. Re-running with the same -Name updates that snippet.
  Code Snippets free runs PHP snippets only, so scope should be a PHP scope (front-end / admin / global).

.PARAMETER Name    Unique snippet name (the idempotency key).
.PARAMETER Code    The PHP body (no <?php tag). Ignored with -Delete.
.PARAMETER Scope   front-end (default) | admin | global | single-use.
.PARAMETER Inactive Create/update the snippet but leave it inactive.
.PARAMETER Delete  Delete the snippet with this name.

.EXAMPLE
  Save-CodeSnippet.ps1 -Name "My fix" -Code 'add_action("wp_footer", function(){ echo "<!-- hi -->"; });'
  Save-CodeSnippet.ps1 -Name "My fix" -Delete
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Name,
  [string]$Code = '',
  [ValidateSet('front-end', 'admin', 'global', 'single-use')][string]$Scope = 'front-end',
  [switch]$Inactive,
  [switch]$Delete
)
$ErrorActionPreference = 'Stop'

$wp = Join-Path $PSScriptRoot '..\..\wp-cli-local\scripts\wp.ps1'
if (-not (Test-Path $wp)) { throw "wp-cli-local wrapper not found at $wp (this skill depends on it)." }

$nB = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Name))
$cB = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Code))
$del = if ($Delete) { 'true' } else { 'false' }
$active = if ($Inactive) { 'false' } else { 'true' }

$php = @'
<?php
if (!function_exists('Code_Snippets\\save_snippet') || !class_exists('Code_Snippets\\Snippet')) {
    echo "ABORT: Code Snippets API unavailable\n"; return;
}
global $wpdb;
$table = $wpdb->prefix . 'snippets';
$name  = base64_decode('__NAME_B64__');
$code  = base64_decode('__CODE_B64__');
$id = (int) $wpdb->get_var($wpdb->prepare("SELECT id FROM {$table} WHERE name = %s", $name));
if (__DELETE__) {
    if ($id) { $wpdb->delete($table, array('id' => $id)); echo "DELETED id={$id}\n"; }
    else { echo "not found: {$name}\n"; }
    return;
}
$s = new Code_Snippets\Snippet();
if ($id) { $s->id = $id; }
$s->name   = $name;
$s->code   = $code;
$s->scope  = '__SCOPE__';
$s->active = __ACTIVE__;
$r = Code_Snippets\save_snippet($s);
if ($r && $r->id) {
    echo (($id ? 'UPDATED' : 'CREATED') . " id={$r->id} scope={$r->scope} type={$r->type}"
        . " active=" . var_export((bool)$r->active, true)
        . " code_error=" . var_export($r->code_error, true) . "\n");
} else { echo "ERROR: save_snippet returned no snippet\n"; }
'@
$php = $php.Replace('__NAME_B64__', $nB).Replace('__CODE_B64__', $cB).Replace('__SCOPE__', $Scope).Replace('__DELETE__', $del).Replace('__ACTIVE__', $active)

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("save-snippet-" + [guid]::NewGuid().ToString('N') + ".php")
Set-Content -LiteralPath $tmp -Value $php -Encoding UTF8
try {
  pwsh -NoProfile -ExecutionPolicy Bypass -File $wp eval-file $tmp
} finally {
  Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
}
