<#
.SYNOPSIS
  Direct MySQL client for the Local (by WP Engine) WordPress database on Windows.

.DESCRIPTION
  Discovers Local's bundled mysql.exe and connects to the site DB
  (host 127.0.0.1, user/pw root/root, db 'local'). Port defaults to 10005 (podcast-local); override
  with -Port. Every other argument is passed straight through to mysql.exe.

  NOTE: this is intentionally a *simple* script (no [CmdletBinding]) so that single-dash mysql flags
  like -e / -h / -u pass through instead of colliding with PowerShell's common parameters.

.EXAMPLE
  pwsh mysql.ps1 -e "SHOW TABLES;"
  pwsh mysql.ps1 -e "SELECT option_name FROM wp_options WHERE option_value LIKE '%/var/www/%';"
  pwsh mysql.ps1 -Port 10005 -e "SELECT VERSION();"
#>
param([int]$Port = 10005)

$ErrorActionPreference = 'Stop'

$roots = @(
  (Join-Path $env:LOCALAPPDATA 'Programs\Local\resources\extraResources\lightning-services'),
  (Join-Path $env:APPDATA      'Local\lightning-services')
) | Where-Object { Test-Path $_ }

$mysql = $roots |
  ForEach-Object { Get-ChildItem -LiteralPath $_ -Directory -Filter 'mysql-*' -ErrorAction SilentlyContinue } |
  Sort-Object Name -Descending |
  ForEach-Object { Join-Path $_.FullName 'bin\win64\bin\mysql.exe' } |
  Where-Object { Test-Path $_ } |
  Select-Object -First 1
if (-not $mysql) { throw "Could not find Local's mysql.exe under lightning-services." }

# $args = everything except -Port (mysql flags like -e pass straight through)
& $mysql "-h127.0.0.1" "-P$Port" "-uroot" "-proot" "local" @args
exit $LASTEXITCODE
