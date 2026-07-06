<#
.SYNOPSIS
  Auto-discovering WP-CLI wrapper for a Local (by WP Engine) WordPress site on Windows.

.DESCRIPTION
  Finds Local's bundled php.exe (newest version), wp-cli.phar, and the site's run-dir php.ini
  (which sets the MySQL port), then runs:  php -c <ini> wp-cli.phar --path=<site> <your args>
  Written for podcast-local but discovers versioned paths at runtime, so a Local PHP update
  won't break it. The harmless php_imagick.dll startup warning is filtered out.

.EXAMPLE
  pwsh wp.ps1                         # no args: print discovered paths (health check)
  pwsh wp.ps1 option get siteurl
  pwsh wp.ps1 plugin list --status=active
  pwsh wp.ps1 eval-file .\scratch\task.php
  pwsh wp.ps1 -RunId abcd1234 -SitePath 'C:\path\to\app\public' option get home
#>
[CmdletBinding(PositionalBinding = $false)]
param(
  [string]$SitePath,
  [string]$RunId,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$WpArgs
)

$ErrorActionPreference = 'Stop'

# --- podcast-local fallbacks (only used if auto-discovery is ambiguous) ---
$DefaultRunId = 'vyyRwerqm'

# --- 1) Resolve the WordPress site path (default: <repo-root>/app/public, 4 levels up) ---
if (-not $SitePath) {
  $SitePath = Join-Path $PSScriptRoot '..\..\..\..\app\public'
}
$resolved = Resolve-Path -LiteralPath $SitePath -ErrorAction SilentlyContinue
if (-not $resolved) { throw "WordPress site path not found: '$SitePath'. Pass -SitePath explicitly." }
$SitePath = $resolved.Path

# --- 2) Discover php.exe (newest php-* under Local's lightning-services) ---
$phpRoots = @(
  (Join-Path $env:APPDATA      'Local\lightning-services'),
  (Join-Path $env:LOCALAPPDATA 'Programs\Local\resources\extraResources\lightning-services')
) | Where-Object { Test-Path $_ }

$php = $phpRoots |
  ForEach-Object { Get-ChildItem -LiteralPath $_ -Directory -Filter 'php-*' -ErrorAction SilentlyContinue } |
  Sort-Object Name -Descending |
  ForEach-Object { Join-Path $_.FullName 'bin\win64\php.exe' } |
  Where-Object { Test-Path $_ } |
  Select-Object -First 1
if (-not $php) { throw "Could not find Local's php.exe under lightning-services." }

# --- 3) Discover wp-cli.phar ---
$wpCli = @(
  (Join-Path $env:LOCALAPPDATA 'Programs\Local\resources\extraResources\bin\wp-cli\wp-cli.phar'),
  (Join-Path $env:APPDATA      'Local\resources\extraResources\bin\wp-cli\wp-cli.phar')
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $wpCli) { throw "Could not find wp-cli.phar under Local's extraResources." }

# --- 4) Discover the run-dir php.ini (defines the MySQL port) ---
$runRoot = Join-Path $env:APPDATA 'Local\run'
if (-not $RunId) {
  if (Test-Path (Join-Path $runRoot $DefaultRunId)) {
    $RunId = $DefaultRunId
  } else {
    $dirs = @(Get-ChildItem -LiteralPath $runRoot -Directory -ErrorAction SilentlyContinue)
    if ($dirs.Count -eq 1) { $RunId = $dirs[0].Name }
    else { throw "Multiple/zero Local run dirs; pass -RunId. Candidates: $($dirs.Name -join ', ')" }
  }
}
$ini = Join-Path $runRoot "$RunId\conf\php\php.ini"
if (-not (Test-Path $ini)) { throw "Run php.ini not found: '$ini'. Pass -RunId." }

# --- No args: print what we found and exit (health check) ---
if (-not $WpArgs -or $WpArgs.Count -eq 0) {
  Write-Host "wp-cli-local ready." -ForegroundColor Green
  Write-Host "  php  : $php"
  Write-Host "  wp   : $wpCli"
  Write-Host "  ini  : $ini"
  Write-Host "  site : $SitePath"
  Write-Host ""
  Write-Host "Usage: wp.ps1 <wp args>   e.g.  wp.ps1 option get siteurl"
  return
}

# --- Run WP-CLI, filtering the harmless php_imagick.dll startup warning ---
& $php -c $ini $wpCli "--path=$SitePath" @WpArgs 2>&1 |
  Where-Object { $_ -notmatch 'php_imagick\.dll' }

exit $LASTEXITCODE
