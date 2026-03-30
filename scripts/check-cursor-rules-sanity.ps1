param(
  [Parameter(Mandatory = $false)]
  [string]$RootPath = "."
)

$ErrorActionPreference = "Stop"

function Resolve-AbsPath([string]$path) {
  return (Resolve-Path -LiteralPath $path).Path
}

$root = Resolve-AbsPath $RootPath
Write-Host "== cursor_rules sanity check =="
Write-Host ("RootPath: " + $root)

$requiredMdc = @(
  "venv-only-common.mdc",
  "errors-debug-unittest-common.mdc",
  "post-modification-common.mdc",
  "gui-build-security-common.mdc",
  "markdown-common.mdc",
  "update-management-common.mdc",
  "checklist-a-all-rules-common.mdc"
)

$rulesDir = Join-Path $root ".cursor\\rules"
if (-not (Test-Path -LiteralPath $rulesDir)) {
  Write-Host ("FAIL: Missing rules directory: " + $rulesDir)
  exit 1
}

$missing = @()
foreach ($f in $requiredMdc) {
  $p = Join-Path $rulesDir $f
  if (-not (Test-Path -LiteralPath $p)) { $missing += $f }
}

if ($missing.Count -gt 0) {
  Write-Host ("FAIL: Missing required .mdc files in " + $rulesDir)
  foreach ($m in $missing) { Write-Host ("- " + $m) }
  exit 1
}

Write-Host "OK: 7 required .mdc files exist."

Write-Host ""
Write-Host "Running markdown TOC check (no fix)."
& powershell -ExecutionPolicy Bypass -File (Join-Path $root "scripts\\check-markdown-toc.ps1") -RootPath $root
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "OK: cursor_rules sanity check passed."
exit 0

