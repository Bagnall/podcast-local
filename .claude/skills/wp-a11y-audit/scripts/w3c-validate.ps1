<#
.SYNOPSIS
  Validate a URL's rendered (server) HTML against the W3C Nu validator and summarise the errors.

.DESCRIPTION
  Fetches the page HTML and POSTs it to https://validator.w3.org/nu/?out=json, then prints a summary:
  total errors, CSS-parse errors, and HTML (non-CSS) errors (the ones that usually matter), listing the
  HTML errors. Use -Full to also list every CSS-parse error.

  NOTE: this sends the page HTML to the external W3C service. Fine for a public site; be mindful if the
  page contains anything sensitive.

.EXAMPLE
  pwsh w3c-validate.ps1 https://podcast.langcen.cam.ac.uk/
  pwsh w3c-validate.ps1 http://podcast-local.local/register-for-updates/ -Full
#>
param(
  [Parameter(Mandatory = $true, Position = 0)][string]$Url,
  [switch]$Full
)

$ErrorActionPreference = 'Stop'
$ua = 'Mozilla/5.0 (wp-a11y-audit W3C check)'

# 1) fetch the page HTML
$html = (Invoke-WebRequest -Uri $Url -UseBasicParsing -Headers @{ 'User-Agent' = $ua }).Content

# 2) POST to the W3C Nu validator (raw HTML body)
$resp = Invoke-RestMethod -Uri 'https://validator.w3.org/nu/?out=json' -Method Post `
  -ContentType 'text/html; charset=utf-8' `
  -Headers @{ 'User-Agent' = $ua } `
  -Body ([System.Text.Encoding]::UTF8.GetBytes($html))

$errors = @($resp.messages | Where-Object { $_.type -eq 'error' })
$css    = @($errors | Where-Object { $_.message -like 'CSS:*' })
$noncss = @($errors | Where-Object { $_.message -notlike 'CSS:*' })

Write-Host "URL: $Url"
Write-Host ("Errors: {0}   |  CSS-parse: {1}   |  HTML (non-CSS): {2}" -f $errors.Count, $css.Count, $noncss.Count) -ForegroundColor Cyan

if ($noncss.Count) {
  Write-Host "`n--- HTML (non-CSS) errors ---" -ForegroundColor Yellow
  $noncss | ForEach-Object {
    Write-Host (" - " + $_.message)
    if ($_.extract) { Write-Host ("     extract: " + ($_.extract -replace '\s+', ' ')) -ForegroundColor DarkGray }
  }
}
if ($Full -and $css.Count) {
  Write-Host "`n--- CSS-parse errors ---" -ForegroundColor Yellow
  $css | ForEach-Object { Write-Host (" - " + $_.message) }
}
if ($errors.Count -eq 0) { Write-Host "`nNo errors. " -ForegroundColor Green }
