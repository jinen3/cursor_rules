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

$updateMdc = Join-Path $rulesDir "update-management-common.mdc"
$tasksTemplate = Join-Path $root "templates\\vscode_tasks.tasks.json.example"
Write-Host ""
Write-Host "Verifying vscode_tasks.tasks.json.example vs CHECKLIST_A_POLICY requiredTaskLabels..."
$policyText = [System.IO.File]::ReadAllText($updateMdc, [System.Text.Encoding]::UTF8)
$m = [Regex]::Match(
  $policyText,
  '<!-- CHECKLIST_A_POLICY_START -->\s*```json\s*(?<json>\{[\s\S]*?\})\s*```\s*<!-- CHECKLIST_A_POLICY_END -->',
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)
if (-not $m.Success) {
  Write-Host "FAIL: Missing CHECKLIST_A_POLICY block in update-management-common.mdc"
  exit 1
}
$policy = $m.Groups["json"].Value.Trim() | ConvertFrom-Json
$labels = @($policy.requiredTaskLabels)
if ($labels.Count -eq 0) {
  Write-Host "FAIL: Policy requiredTaskLabels is empty"
  exit 1
}
if (-not (Test-Path -LiteralPath $tasksTemplate)) {
  Write-Host ("FAIL: Missing tasks template: " + $tasksTemplate)
  exit 1
}
$tasksJson = Get-Content -LiteralPath $tasksTemplate -Raw -Encoding UTF8 | ConvertFrom-Json
$present = @{}
foreach ($t in @($tasksJson.tasks)) {
  if ($null -ne $t.label) { $present[[string]$t.label] = $true }
}
$missingLabels = @()
foreach ($lab in $labels) {
  if (-not $present.ContainsKey([string]$lab)) { $missingLabels += [string]$lab }
}
if ($missingLabels.Count -gt 0) {
  Write-Host "FAIL: templates/vscode_tasks.tasks.json.example is missing required task label(s):"
  foreach ($x in $missingLabels) { Write-Host ("- " + $x) }
  Write-Host "Fix: add tasks with these exact labels, or update CHECKLIST_A_POLICY if intentional."
  exit 1
}
Write-Host "OK: tasks template contains all requiredTaskLabels from policy."

Write-Host ""
Write-Host "Running markdown TOC check (no fix)."
& powershell -ExecutionPolicy Bypass -File (Join-Path $root "scripts\\check-markdown-toc.ps1") -RootPath $root
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "OK: cursor_rules sanity check passed."
exit 0

